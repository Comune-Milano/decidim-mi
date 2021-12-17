PID=$(ps -ef | grep decidim_milano | grep -v grep | awk {'print $2'})
sudo kill -9 $PID
