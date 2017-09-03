#cd ../..
echo "pwd:" `pwd`
echo "ls *.yaml"
echo "remove current stack yaml"
rm stack*.yaml
echo "restoring old stack-docker"
cp automation/deploy/stack-originals/stack-dock.yaml stack.yaml
