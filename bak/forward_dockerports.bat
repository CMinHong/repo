@echo off
rem 获取docker容器的端口，并转发

for /f "tokens=*" %%a in ('ssh -t -p2333 takashi.buzz "sudo -S docker ps -q | xargs -I %% sudo -S docker port %% | grep -Po '(?<=[^]]:)\d+$' | tr '\n' ' ' | sed 's/\(\S\+\)\s/-L \1:10.0.0.1:\1 /g'"') do set files=%%a

echo %files%

ssh %files% takashi.buzz -p2333