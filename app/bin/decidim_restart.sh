PID=$(ps -ef | grep decidim_milano | grep -v grep | awk {'print $2'})
sudo kill -9 $PID
nohup rails server -p 3333 -b 0.0.0.0 &
