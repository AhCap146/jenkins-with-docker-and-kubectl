@echo off
setlocal

REM Jenkins pod name
set /p JENKINS_POD="Enter the Jenkins pod name: "

REM Kubernetes namespace
set /p NAMESPACE="Enter Kubernetes namespace: "

REM Copy the certificates to the specified pod
echo Copying client.crt to /tmp/client.crt in pod %JENKINS_POD%...
kubectl cp client.crt %JENKINS_POD%:/tmp/client.crt -n %NAMESPACE%

echo Copying client.key to /tmp/client.key in pod %JENKINS_POD%...
kubectl cp client.key %JENKINS_POD%:/tmp/client.key -n %NAMESPACE%

echo Copying ca.crt to /tmp/ca.crt in pod %JENKINS_POD%...
kubectl cp ca.crt %JENKINS_POD%:/tmp/ca.crt -n %NAMESPACE%

echo All files have been copied successfully.

endlocal
pause
