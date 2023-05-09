<?php

include_once('Report.php');

$jasperPath = getcwd() . '/' . APPPATH . 'libraries/integration/jasper';
define('JASPER_PATH', $jasperPath);

class JasperReport extends Report {

    private $jasperFile;

    private $parameters = array();
    private $data = null;

    public function __construct($jasperFile) {
        $this->jasperFile = $jasperFile;
    }

    public function addParameter($name, $value) {
        $this->parameters[$name] = $value;
    }

    public function addSubReport($subReportName, $subReportFile) {
        $this->addParameter($subReportName, JASPER_PATH . "/reports/{$subReportFile}");
    }

    public function setData($data) {
        $this->data = $data;
    }

    public function toPdf() {
        $jasperFile = JASPER_PATH . "/reports/{$this->jasperFile}";

        $jarCommand = "java -jar generate-jasper.jar --jasperFile=\"{$jasperFile}\" --locale=en_US ";

        foreach ($this->parameters as $name => $value) {
            $jarCommand .= " -P{$name}=\"${value}\"";
        }

        if (empty($this->data)) {
            $jarCommand .= ' --noData';
        }

        if (empty($params)) {
            $params = '';
        }

        $descriptorSpec = array(
            0 => array("pipe", "r"),
            1 => array("pipe", "w"),
            2 => array("pipe", "w")
        );

        $process = proc_open($jarCommand, $descriptorSpec, $pipes, JASPER_PATH . '/jars/');

        if (!empty($this->data)) {
            fwrite($pipes[0], json_encode($this->data)."\n");
        }

        $output = stream_get_contents($pipes[1]);

        $error = stream_get_contents($pipes[2]);

        fclose($pipes[0]);
        fclose($pipes[1]);
        fclose($pipes[2]);

        $statusCode = proc_close($process);

        if ($statusCode != 0) {
            throw new Exception($error);
        }

        return $output;
    }

    public static function getInstance($jasperFile) {
        return new JasperReport($jasperFile);
    }
}
