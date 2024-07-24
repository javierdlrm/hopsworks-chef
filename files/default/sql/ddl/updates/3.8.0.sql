-- HWORKS-987
ALTER TABLE `hopsworks`.`model_version` ADD CONSTRAINT `model_version_key` UNIQUE (`model_id`,`version`);
ALTER TABLE `hopsworks`.`model_version` DROP PRIMARY KEY;
ALTER TABLE `hopsworks`.`model_version` ADD COLUMN id int(11) AUTO_INCREMENT PRIMARY KEY;

-- FSTORE-1190
ALTER TABLE `hopsworks`.`embedding_feature`
    ADD COLUMN `model_version_id` INT(11) NULL;

ALTER TABLE `hopsworks`.`embedding_feature`
    ADD CONSTRAINT `embedding_feature_model_version_fk` FOREIGN KEY (`model_version_id`) REFERENCES `model_version` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`serving` ADD COLUMN `api_protocol` TINYINT(1) NOT NULL DEFAULT '0';

-- FSTORE-1096
ALTER TABLE `hopsworks`.`feature_store_jdbc_connector`
    ADD COLUMN `secret_uid` INT DEFAULT NULL,
    ADD COLUMN `secret_name` VARCHAR(200) DEFAULT NULL;

-- FSTORE-1248
ALTER TABLE `hopsworks`.`executions`
    ADD COLUMN `notebook_out_path` varchar(255) COLLATE latin1_general_cs DEFAULT NULL;

CREATE TABLE IF NOT EXISTS `hopsworks`.`model_link` (
  `id` int NOT NULL AUTO_INCREMENT,
  `model_version_id` int(11) NOT NULL,
  `parent_training_dataset_id` int(11),
  `parent_feature_store` varchar(100) NOT NULL,
  `parent_feature_view_name` varchar(63) NOT NULL,
  `parent_feature_view_version` int(11) NOT NULL,
  `parent_training_dataset_version` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `link_unique` (`model_version_id`, `parent_training_dataset_id`),
  KEY `model_version_id_fkc` (`model_version_id`),
  KEY `parent_training_dataset_id_fkc` (`parent_training_dataset_id`),
  CONSTRAINT `model_version_id_fkc` FOREIGN KEY (`model_version_id`) REFERENCES `hopsworks`.`model_version` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `training_dataset_parent_fkc` FOREIGN KEY (`parent_training_dataset_id`) REFERENCES `hopsworks`.`training_dataset` (`id`) ON DELETE SET NULL ON UPDATE NO ACTION
) ENGINE=ndbcluster DEFAULT CHARSET=latin1 COLLATE=latin1_general_cs;

-- FSTORE-920
ALTER TABLE `hopsworks`.`feature_store_jdbc_connector`
    ADD `driver_path` VARCHAR(2000) DEFAULT NULL;

-- HWORKS-1235
ALTER TABLE `hopsworks`.`serving` ADD COLUMN `deployed_by` int(11) DEFAULT NULL;
ALTER TABLE `hopsworks`.`serving` ADD KEY `deployed_by_fk` (`deployed_by`);
ALTER TABLE `hopsworks`.`serving` ADD CONSTRAINT `deployed_by_fk_serving` FOREIGN KEY (`deployed_by`) REFERENCES `users` (`uid`) ON DELETE CASCADE ON UPDATE NO ACTION;

-- FSTORE-1412
CREATE TABLE IF NOT EXISTS `hopsworks`.`feature_statistics_config` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `feature_name` VARCHAR(63) COLLATE latin1_general_cs NOT NULL,
    `feature_monitoring_config_id` INT(11) NOT NULL,
    PRIMARY KEY (`id`),
    KEY (`feature_name`),
    KEY (`feature_monitoring_config_id`),
    UNIQUE KEY `feature_statistics_config_UNIQUE` (`feature_monitoring_config_id`, `feature_name`),
    CONSTRAINT `feature_statistics_config_fm_config_fk` FOREIGN KEY (`feature_monitoring_config_id`) REFERENCES `hopsworks`.`feature_monitoring_config` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

ALTER TABLE `hopsworks`.`statistics_comparison_config`
    ADD COLUMN `specific_value` FLOAT DEFAULT NULL,
    ADD COLUMN `feature_statistics_config_id` INT(11) NOT NULL,
    ADD KEY (`feature_statistics_config_id`),
    ADD CONSTRAINT `feature_statistics_config_sc_config_fk` FOREIGN KEY (`feature_statistics_config_id`) REFERENCES `hopsworks`.`feature_statistics_config` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION;

ALTER TABLE `hopsworks`.`monitoring_window_config`
    DROP COLUMN `specific_value`;

ALTER TABLE `hopsworks`.`feature_monitoring_config`
    DROP KEY `feature_name`,
    DROP FOREIGN KEY `statistics_comparison_config_monitoring_config_fk`,
    DROP FOREIGN KEY `job_monitoring_config_fk`,
    DROP COLUMN `feature_name`,
    DROP COLUMN `statistics_comparison_config_id`;

ALTER TABLE `hopsworks`.`feature_monitoring_config`
    ADD CONSTRAINT `job_monitoring_config_fk` FOREIGN KEY (`job_id`) REFERENCES `jobs` (`id`) ON DELETE RESTRICT ON UPDATE NO ACTION;

CREATE TABLE IF NOT EXISTS `feature_statistics_result` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `feature_monitoring_result_id` INT(11) NOT NULL,
    `feature_name` VARCHAR(63) COLLATE latin1_general_cs NOT NULL,
    `detection_stats_id` INT(11),
    `reference_stats_id` INT(11),
    `shifted_metric_names` VARCHAR(170) DEFAULT NULL,
    PRIMARY KEY (`id`),
    KEY (`feature_name`),
    KEY (`feature_monitoring_result_id`),
    UNIQUE KEY `feature_statistics_result_UNIQUE` (`feature_name`, `feature_monitoring_result_id`),
    CONSTRAINT `feature_monitoring_statistics_result_fk` FOREIGN KEY (`feature_monitoring_result_id`) REFERENCES `feature_monitoring_result` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `detection_stats_feat_stats_result_fk` FOREIGN KEY (`detection_stats_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION,
    CONSTRAINT `reference_stats_feat_stats_result_fk` FOREIGN KEY (`reference_stats_id`) REFERENCES `feature_descriptive_statistics` (`id`) ON DELETE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

CREATE TABLE IF NOT EXISTS `statistics_comparison_result` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `feature_statistics_result_id` INT(11) NOT NULL,
    `statistics_comparison_config_id` INT(11) NOT NULL,
    `difference` FLOAT DEFAULT NULL,
    `shift_detected` BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (`id`),
    KEY (`feature_statistics_result_id`),
    KEY (`statistics_comparison_config_id`),
    UNIQUE KEY `feature_statistics_comparison_result_UNIQUE` (`feature_statistics_result_id`, `statistics_comparison_config_id`),
    CONSTRAINT `statistics_comparison_result_f_stats_result_fk` FOREIGN KEY (`feature_statistics_result_id`) REFERENCES `hopsworks`.`feature_statistics_result` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT `statistics_comparison_result_config_fk` FOREIGN KEY (`statistics_comparison_config_id`) REFERENCES `hopsworks`.`statistics_comparison_config` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE = ndbcluster DEFAULT CHARSET = latin1 COLLATE = latin1_general_cs;

ALTER TABLE `hopsworks`.`feature_monitoring_result`
    DROP FOREIGN KEY `detection_stats_monitoring_result_fk`,
    DROP FOREIGN KEY `reference_stats_monitoring_result_fk`,
    DROP COLUMN `detection_stats_id`,
    DROP COLUMN `reference_stats_id`,
    DROP COLUMN `feature_name`,
    DROP COLUMN `shift_detected`,
    DROP COLUMN `difference`,
    DROP COLUMN `specific_value`;

ALTER TABLE `hopsworks`.`feature_monitoring_result`
    ADD `shifted_feature_names` VARCHAR(1500) DEFAULT NULL;

ALTER TABLE `hopsworks`.`job_schedule`
    ADD COLUMN `last_execution_date_time` timestamp;