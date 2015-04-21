SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP SCHEMA IF EXISTS `survey` ;
CREATE SCHEMA IF NOT EXISTS `survey` DEFAULT CHARACTER SET utf8 ;
USE `survey` ;

-- -----------------------------------------------------
-- Table `survey`.`responses_main`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `survey`.`responses_main` ;

CREATE  TABLE IF NOT EXISTS `survey`.`responses_main` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `respondentId` INT NULL DEFAULT NULL ,
  `respondentName` VARCHAR(100) NULL DEFAULT NULL ,
  `respondentEmail` VARCHAR(100) NULL DEFAULT NULL ,
  `q1` INT NULL DEFAULT NULL ,
  `q4` VARCHAR(45) NULL DEFAULT NULL ,
  `q6a` VARCHAR(45) NULL DEFAULT NULL ,
  `q6b` TEXT NULL DEFAULT NULL ,
  `q7a` VARCHAR(45) NULL DEFAULT NULL ,
  `q7b` TEXT NULL DEFAULT NULL ,
  `feedback` TEXT NULL ,
  `writeCode` TINYINT(1) NULL DEFAULT NULL ,
  `testCode` TINYINT(1) NULL DEFAULT NULL ,
  `reviewCode` TINYINT(1) NULL DEFAULT NULL ,
  `design` TINYINT(1) NULL DEFAULT NULL ,
  `maintenance` TINYINT(1) NULL DEFAULT NULL ,
  `fixDefects` TINYINT(1) NULL DEFAULT NULL ,
  `steerOverallDir` TINYINT(1) NULL DEFAULT NULL ,
  `otherRole` TINYINT(1) NULL DEFAULT NULL ,
  `otherRoleText` TEXT NULL DEFAULT NULL ,
  `responseEmail` VARCHAR(100) NULL DEFAULT NULL ,
  `clusterId` INT NULL DEFAULT NULL ,
  `projectName` VARCHAR(45) NULL DEFAULT NULL ,
  `projectId` INT NULL DEFAULT NULL ,
  `projectVersion` VARCHAR(100) NULL DEFAULT NULL ,
  `indexError` TINYINT(1) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `survey`.`responses_q5`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `survey`.`responses_q5` ;

CREATE  TABLE IF NOT EXISTS `survey`.`responses_q5` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `responseId` INT NULL DEFAULT NULL ,
  `devId` INT NULL DEFAULT NULL ,
  `devName` VARCHAR(100) NULL DEFAULT NULL ,
  `response` VARCHAR(45) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `id_idx` (`responseId` ASC) ,
  CONSTRAINT `q5`
    FOREIGN KEY (`responseId` )
    REFERENCES `survey`.`responses_main` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `survey`.`responses_q2`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `survey`.`responses_q2` ;

CREATE  TABLE IF NOT EXISTS `survey`.`responses_q2` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `responseId` INT NOT NULL ,
  `devName` VARCHAR(100) NULL DEFAULT NULL ,
  `relationshipStrength` VARCHAR(100) NULL DEFAULT NULL ,
  `relationshipType` VARCHAR(255) NULL DEFAULT NULL ,
  `comment` TEXT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `responseId_idx` (`responseId` ASC) ,
  CONSTRAINT `q2`
    FOREIGN KEY (`responseId` )
    REFERENCES `survey`.`responses_main` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `survey`.`responses_q3`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `survey`.`responses_q3` ;

CREATE  TABLE IF NOT EXISTS `survey`.`responses_q3` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `responseId` INT NULL DEFAULT NULL ,
  `devName` VARCHAR(100) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `responseId_idx` (`responseId` ASC) ,
  CONSTRAINT `q3`
    FOREIGN KEY (`responseId` )
    REFERENCES `survey`.`responses_main` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `survey`.`responses_q7_c`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `survey`.`responses_q7_c` ;

CREATE  TABLE IF NOT EXISTS `survey`.`responses_q7_c` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `responseId` INT NULL DEFAULT NULL ,
  `devName` VARCHAR(100) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `q7_c_idx` (`responseId` ASC) ,
  CONSTRAINT `q7_c`
    FOREIGN KEY (`responseId` )
    REFERENCES `survey`.`responses_main` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `survey`.`responses_q7_d`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `survey`.`responses_q7_d` ;

CREATE  TABLE IF NOT EXISTS `survey`.`responses_q7_d` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `responseId` INT NULL DEFAULT NULL ,
  `devName` VARCHAR(100) NULL DEFAULT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `q7_d_idx` (`responseId` ASC) ,
  CONSTRAINT `q7_d`
    FOREIGN KEY (`responseId` )
    REFERENCES `survey`.`responses_main` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
