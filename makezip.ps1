# creates main.zip file with requires files for PS lab
Compress-Archive -Path .\*.tf,.\*.sh,.\src\ -DestinationPath .\main.zip -Update




# add tf debugging log
New-Item -Path ENV: -Name 'TF_LOG' -Value TRACE
New-Item -Path ENV: -Name 'TF_LOG_PATH' -Value './log/tf_debug.log'
