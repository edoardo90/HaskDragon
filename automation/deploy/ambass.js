const shell = require('shelljs');
const colors = require('colors');
const path = require('path')

const projectDir  = path.resolve(__dirname, '..', '..');

const inProduction = false

const stackBuild = 'stack build --system-ghc ' + (inProduction ? '' : ' --fast ')
const stackVersion = 'stack --version'

function makeStackCommand(command){
  return `
    docker run -v \`pwd\`:/project \
    -v \`pwd\`/automation/docker-setup:/root/.stack \
    -i  debian-stack-edo ${command}
  `
}

function build() {
    return new Promise((resolve, reject) => {
      shell.cd(projectDir);

      const stackBuildCmd = makeStackCommand(stackBuild);
      console.log("stackBuild command:\n", stackBuildCmd)

      console.log("4 - BUILD  - ls *.yaml: \n".bold)
      shell.ls('*.yaml').forEach(file => console.log( "4 - D ", file))

      shell.exec(stackBuildCmd, function(code, stdout, stderr) {
        console.log('5 - after build command - Exit code:'.yellow, code);

        if(code) {
          console.log("5A - build failed");
          console.log('5A - Program stderr:', stderr.slice(0, 200), "[..]");
          return correctBuild(stderr).then(res => resolve(res));

        } else {
          console.log("build success".green);

          let install = (stderr.match(/Installing executable\(s\).+\s+\/project\/(.+)/i))
          if(install && (install = install[1])){
            console.log("install dir :", install)
            return resolve(install);
          }

          console.log('6 - Program output:', stdout);
          console.log(" 6 - ::::::::::::. after build command".yellow)
          shell.ls('*.yaml').forEach(file => console.log(" 6 - AB - ", file))

          return resolve('');
        }
      });
    })
}

function correctBuild(err){
  return new Promise(resolve, reject => {

    if(typeof err === 'object'){
      err = JSON.stringify(err);
    }

    console.log(" 7 - trying to fix ", err.slice(0, 200), " [...] ".yellow)
    if(err.match(/stack solver/gi)){
      console.log("7A - SOLVER ERROR - stack solver way ")
      console.log(" stack solver --system-ghc --update-config ".white)

      shell.exec('stack solver --system-ghc --update-config', function(code, solverOut, solverErr){

        if(code){
          console.log("7.1A - stack solver was not successfull  ".red)
          console.log("solver err:", solverErr)
          return resolve('');
        }
        else {
          console.log("7.1B - stack solver was successfull .. ".yellow)

          let unchanged = solverErr.match(/No changes needed/gi);

          if(unchanged){
            console.log(" 7.2A - .. no changes needed".red);
            if(err.match(/try adding the following to your extra-deps in/gi)){
              let m = err.match(/try adding the following to your extra-deps in \/project\/stack\.yaml:\s+/)
              var ms = (err.match(/try adding the following to your extra-deps in.+\s+(.+\s+)+\s+You may also/i))

              if(ms && ms[1]){
                console.log("deps:", ms[1])
                return resolve(ms[1]);
              }

            } else {
              return build().then(res => resolve(res));
            }

          } else {
            console.log(" 7.2B - .. build configuration corrected, lets try!".green);
            console.log("stack solver out:".yellow, solverOut.slice(0, 100), "[...]".green,  solverOut.slice(-100) )
            console.log(" 7.3 - build corrected!".green);
            return  build().then(res => resolve(res));
          }
        }
      })
    } else {
      console.log(" 7B - NO SOLVER ERROR :".red, err, "7B - message:", err, " we don't know how to fix it")
      return build().then(res => resolve(res));
    }

  })
}


function preBuild(){
  return new Promise(function(resolve, reject) {
    shell.cd(projectDir);
    shell.exec('./restore-docker-yaml', (c, e, o) => resolve(c));
  });
}

function postBuild(instsallDir){
  return new Promise(function(resolve, reject) {
    shell.cd(projectDir);
    shell.exec('./restore-original-yaml', (c, e, o) => resolve(installDir));
  });
}

function sshUploadBin(installDir) {



}


preBuild()
  // .then(build)
  // .then(postBuild)
  .then(sshUploadBin);


//
