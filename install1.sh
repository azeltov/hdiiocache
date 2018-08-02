sudo mkdir -p /usr/lib/rubix

sudo rm -f /usr/lib/rubix/rubix-core-0.3.0.2.6.99.201-SNAPSHOT.jar
sudo rm -f /usr/lib/rubix/rubix-spi-0.3.0.2.6.99.201-SNAPSHOT.jar
sudo rm -f /usr/lib/rubix/rubix-hadoop2-0.3.0.2.6.99.201-SNAPSHOT.jar
sudo rm -f /usr/lib/rubix/rubix-bookkeeper-0.3.0.2.6.99.201-SNAPSHOT.jar

sudo wget https://dastorageeastus.blob.core.windows.net/rubixjars/rubix-spi-0.3.0.2.6.99.201-SNAPSHOT.jar -O /usr/lib/rubix/rubix-spi-0.3.0.2.6.99.201-SNAPSHOT.jar
sudo wget https://dastorageeastus.blob.core.windows.net/rubixjars/rubix-core-0.3.0.2.6.99.201-SNAPSHOT.jar -O /usr/lib/rubix/rubix-core-0.3.0.2.6.99.201-SNAPSHOT.jar
sudo wget https://dastorageeastus.blob.core.windows.net/rubixjars/rubix-hadoop2-0.3.0.2.6.99.201-SNAPSHOT.jar -O /usr/lib/rubix/rubix-hadoop2-0.3.0.2.6.99.201-SNAPSHOT.jar
sudo wget https://dastorageeastus.blob.core.windows.net/rubixjars/rubix-bookkeeper-0.3.0.2.6.99.201-SNAPSHOT.jar -O /usr/lib/rubix/rubix-bookkeeper-0.3.0.2.6.99.201-SNAPSHOT.jar
sudo wget https://dastorageeastus.blob.core.windows.net/rubixjars/rubix-presto-0.3.0.2.6.99.201-SNAPSHOT.jar -O /usr/lib/rubix/rubix-presto-0.3.0.2.6.99.201-SNAPSHOT.jar
sudo wget https://dastorageeastus.blob.core.windows.net/rubixjars/rubix-rpm-0.3.0.2.6.99.201-SNAPSHOT.jar -O /usr/lib/rubix/rubix-rpm-0.3.0.2.6.99.201-SNAPSHOT.jar

sudo ln -sf -t /usr/hdp/current/hadoop-client/lib/ /usr/lib/rubix/*.jar
sudo ln -sf -t /usr/hdp/current/spark2-client/jars/ /usr/lib/rubix/*.jar
sudo ln -sf -t /var/lib/ambari-server/resources/views/work/HIVE\{2.0.0\}/WEB-INF/lib/ /usr/lib/rubix/*.jar

export LOG4J_FILE_BKS=${LOG4J_FILE_BKS:-/etc/rubix/log4j.properties}
export LOG4J_FILE_LDS=${LOG4J_FILE_LDS:-/etc/rubix/log4j_lds.properties}
export RUBIX_LIB_PATH=${RUBIX_LIB_PATH:-/usr/lib/rubix}
export RUBIX_CACHE_DIRPREFIX=${RUBIX_CACHE_DIRPREFIX:-/mnt/rubix/}

sudo rm -rf "$RUBIX_CACHE_DIRPREFIX*"
for n in {0..4}; do
  echo "mkdir -p $RUBIX_CACHE_DIRPREFIX$n/"
  sudo mkdir -p $RUBIX_CACHE_DIRPREFIX$n/
done

sudo mkdir -p /etc/rubix
sudo mkdir -p /var/log/rubix
sudo wget https://dastorageeastus.blob.core.windows.net/rubixjars/log4j.properties -O /etc/rubix/log4j.properties
sudo wget https://dastorageeastus.blob.core.windows.net/rubixjars/log4j_lds.properties -O /etc/rubix/log4j_lds.properties

export HADOOP_OPTS="${HADOOP_OPTS} -Dlog4j.configuration=file://${LOG4J_FILE_BKS}"
nohup hadoop jar $RUBIX_LIB_PATH/rubix-bookkeeper-*.jar com.qubole.rubix.bookkeeper.BookKeeperServer -Dhadoop.cache.data.dirprefix.list=$RUBIX_CACHE_DIRPREFIX &
PID=$!
echo $PID > /var/run/iocache-bookkeeper.pid
echo "Starting Cache BookKeeper server with pid $PID"

export HADOOP_OPTS="${HADOOP_OPTS} -Dlog4j.configuration=file://${LOG4J_FILE_LDS}"
nohup hadoop jar $RUBIX_LIB_PATH/rubix-bookkeeper-*.jar com.qubole.rubix.bookkeeper.LocalDataTransferServer &
PIDL=$!
echo $PIDL > /var/run/iocache-localdatatransfer.pid
echo "Starting Local Transfer server with pid $PIDL"