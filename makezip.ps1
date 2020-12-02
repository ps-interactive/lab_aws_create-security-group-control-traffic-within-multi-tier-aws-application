# creates main.zip file with requires files for PS lab
Compress-Archive -Path .\*.tf,.\*.sh,.\src\ -DestinationPath .\main.zip -Update