 #!/bin/bash
set +x

apt-get install ca-certificates curl gnupg lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
docker pull collabora/code

docker run -t -d -p 127.0.0.1:9980:9980 -e "domain=cloud\\.rockhopsoft\\.com|pantry\\.gnomie\\.cloud" -e "username=colladmin" -e "password=Asg*@#98wefj!*gjsg0" --restart always --cap-add MKNOD collabora/code

# https://computingforgeeks.com/deploy-collabora-online-office-on-ubuntu-with-lets-encrypt-ssl/
nano /etc/apache2/sites-available/collabora-online.conf

certbot --authenticator standalone --installer apache -d collabora.rockhopsoft.com --pre-hook "service apache2 stop" --post-hook "service apache2 start"


docker stop collabora/code
