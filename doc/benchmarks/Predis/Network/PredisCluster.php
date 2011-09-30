<?php

namespace Predis\Network;

use Predis\Helpers;
use Predis\ClientException;
use Predis\Commands\ICommand;
use Predis\Distribution\IDistributionStrategy;
use Predis\Distribution\HashRing;

class PredisCluster implements IConnectionCluster, \IteratorAggregate {
    private $_pool;
    private $_distributor;

    public function __construct(IDistributionStrategy $distributor = null) {
        $this->_pool = array();
        $this->_distributor = $distributor ?: new HashRing();
    }

    public function isConnected() {
        foreach ($this->_pool as $connection) {
            if ($connection->isConnected()) {
                return true;
            }
        }
        return false;
    }

    public function connect() {
        foreach ($this->_pool as $connection) {
            $connection->connect();
        }
    }

    public function disconnect() {
        foreach ($this->_pool as $connection) {
            $connection->disconnect();
        }
    }

    public function add(IConnectionSingle $connection) {
        $parameters = $connection->getParameters();
        if (isset($parameters->alias)) {
            $this->_pool[$parameters->alias] = $connection;
        }
        else {
            $this->_pool[] = $connection;
        }
        $this->_distributor->add($connection, $parameters->weight);
    }

    public function getConnection(ICommand $command) {
        $cmdHash = $command->getHash($this->_distributor);
        if (isset($cmdHash)) {
            return $this->_distributor->get($cmdHash);
        }
        throw new ClientException(
            sprintf("Cannot send '%s' commands to a cluster of connections", $command->getId())
        );
    }

    public function getConnectionById($id = null) {
        $alias = $id ?: 0;
        return isset($this->_pool[$alias]) ? $this->_pool[$alias] : null;
    }

    public function getConnectionByKey($key) {
        $hashablePart = Helpers::getKeyHashablePart($key);
        $keyHash = $this->_distributor->generateKey($hashablePart);
        return $this->_distributor->get($keyHash);
    }

    public function getIterator() {
        return new \ArrayIterator($this->_pool);
    }

    public function writeCommand(ICommand $command) {
        $this->getConnection($command)->writeCommand($command);
    }

    public function readResponse(ICommand $command) {
        return $this->getConnection($command)->readResponse($command);
    }

    public function executeCommand(ICommand $command) {
        return $this->getConnection($command)->executeCommand($command);
    }
}
