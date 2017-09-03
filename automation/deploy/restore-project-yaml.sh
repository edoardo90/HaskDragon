#cd ../..
echo "pwd:" `pwd`
echo "ls *.yaml"
echo "remove current stack yaml"
rm stack*.yaml
echo "restoring old stack-project"
cp automation/deploy/stack-originals/stack-project.yaml stack.yaml
