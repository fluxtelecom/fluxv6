<?php

abstract class Report {

    public abstract function addParameter($name, $value);

    public abstract function setData($data);

    public abstract function toPdf();

}