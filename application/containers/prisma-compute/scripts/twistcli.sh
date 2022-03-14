for image in images_used
do
   # Download the image to validate the twistcli
   docker pull $image
   # Download the twistcli
   curl -k -u TwistCli-Username:TwistCli-Password -L -o ./twistcli https://europe-west3.cloud.twistlock.com/eu-2-143543845/api/v1/util/twistcli
   # Assign Execute permission
   chmod +x ./twistcli
   # Execute twistcli command
   ./twistcli images scan --details --address https://europe-west3.cloud.twistlock.com/eu-2-143543845 -u 'TwistCli-Username' -p 'TwistCli-Password' $image
   docker tag $image registry-plteun.shsrv.platform.mnscorp.net/openjdk:7
done
