<?php

namespace Predis\Protocol\Text;

use Predis\Helpers;
use Predis\Protocol\IResponseHandler;
use Predis\Protocol\ProtocolException;
use Predis\Network\IConnectionComposable;

class ResponseMultiBulkHandler implements IResponseHandler {
    public function handle(IConnectionComposable $connection, $lengthString) {
        $length = (int) $lengthString;
        if ($length != $lengthString) {
            Helpers::onCommunicationException(new ProtocolException(
                $connection, "Cannot parse '$length' as data length"
            ));
        }

        if ($length === -1) {
            return null;
        }

        $list = array();
        if ($length > 0) {
            $handlersCache = array();
            $reader = $connection->getProtocol()->getReader();
            for ($i = 0; $i < $length; $i++) {
                $header = $connection->readLine();
                $prefix = $header[0];
                if (isset($handlersCache[$prefix])) {
                    $handler = $handlersCache[$prefix];
                }
                else {
                    $handler = $reader->getHandler($prefix);
                    $handlersCache[$prefix] = $handler;
                }
                $list[$i] = $handler->handle($connection, substr($header, 1));
            }
        }
        return $list;
    }
}
