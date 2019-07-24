DROP TABLE IF EXISTS `secrets`;

ALTER TABLE `hopsworks`.`users` DROP COLUMN `validation_key_updated`;
ALTER TABLE `hopsworks`.`users` DROP COLUMN `validation_key_type`;
ALTER TABLE `hopsworks`.`users` CHANGE COLUMN `activated` `activated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;