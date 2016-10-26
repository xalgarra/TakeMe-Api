-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema takemelegends
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema takemelegends
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `takemelegends` DEFAULT CHARACTER SET utf8 ;
USE `takemelegends` ;

-- -----------------------------------------------------
-- Table `takemelegends`.`events`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `takemelegends`.`events` ;

CREATE TABLE IF NOT EXISTS `takemelegends`.`events` (
  `id` VARCHAR(255) NOT NULL,
  `all_day` INT NOT NULL,
  `start_time` DATETIME NULL,
  `stop_time` DATETIME NULL,
  `number_attendances` INT NOT NULL DEFAULT 0,
  `takes` INT NOT NULL DEFAULT 5,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `takemelegends`.`users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `takemelegends`.`users` ;

CREATE TABLE IF NOT EXISTS `takemelegends`.`users` (
  `uid` INT NOT NULL,
  `provider` VARCHAR(30) NOT NULL,
  `name` VARCHAR(30) NULL,
  `surname` VARCHAR(30) NULL,
  `email` VARCHAR(50) NULL,
  `takes` INT NULL,
  `experience` INT NULL,
  `level` INT NULL,
  PRIMARY KEY (`uid`, `provider`),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `takemelegends`.`attendances`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `takemelegends`.`attendances` ;

CREATE TABLE IF NOT EXISTS `takemelegends`.`attendances` (
  `events_id` VARCHAR(255) NOT NULL,
  `users_uid` INT NOT NULL,
  `users_provider` VARCHAR(30) NOT NULL,
  `checkin_done` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`events_id`, `users_uid`, `users_provider`),
  INDEX `fk_events_has_users_users1_idx` (`users_uid` ASC, `users_provider` ASC),
  INDEX `fk_events_has_users_events_idx` (`events_id` ASC),
  CONSTRAINT `fk_events_has_users_events`
    FOREIGN KEY (`events_id`)
    REFERENCES `takemelegends`.`events` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_events_has_users_users1`
    FOREIGN KEY (`users_uid` , `users_provider`)
    REFERENCES `takemelegends`.`users` (`uid` , `provider`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `takemelegends`.`rewards`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `takemelegends`.`rewards` ;

CREATE TABLE IF NOT EXISTS `takemelegends`.`rewards` (
  `name` VARCHAR(100) NOT NULL,
  `description` VARCHAR(500) NULL,
  `takes` INT NULL,
  `level` INT NULL,
  PRIMARY KEY (`name`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `takemelegends`.`purchases`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `takemelegends`.`purchases` ;

CREATE TABLE IF NOT EXISTS `takemelegends`.`purchases` (
  `users_uid` INT NOT NULL,
  `users_provider` VARCHAR(30) NOT NULL,
  `rewards_name` VARCHAR(100) NOT NULL,
  `amount` INT NOT NULL,
  PRIMARY KEY (`users_uid`, `users_provider`, `rewards_name`),
  INDEX `fk_users_has_rewards_rewards1_idx` (`rewards_name` ASC),
  INDEX `fk_users_has_rewards_users1_idx` (`users_uid` ASC, `users_provider` ASC),
  CONSTRAINT `fk_users_has_rewards_users1`
    FOREIGN KEY (`users_uid` , `users_provider`)
    REFERENCES `takemelegends`.`users` (`uid` , `provider`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_users_has_rewards_rewards1`
    FOREIGN KEY (`rewards_name`)
    REFERENCES `takemelegends`.`rewards` (`name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `takemelegends`.`achievements`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `takemelegends`.`achievements` ;

CREATE TABLE IF NOT EXISTS `takemelegends`.`achievements` (
  `name` VARCHAR(100) NOT NULL,
  `description` VARCHAR(500) NULL,
  PRIMARY KEY (`name`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `takemelegends`.`acquisitions`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `takemelegends`.`acquisitions` ;

CREATE TABLE IF NOT EXISTS `takemelegends`.`acquisitions` (
  `users_uid` INT NOT NULL,
  `users_provider` VARCHAR(30) NOT NULL,
  `achievements_name` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`users_uid`, `users_provider`, `achievements_name`),
  INDEX `fk_users_has_achievements_achievements1_idx` (`achievements_name` ASC),
  INDEX `fk_users_has_achievements_users1_idx` (`users_uid` ASC, `users_provider` ASC),
  CONSTRAINT `fk_users_has_achievements_users1`
    FOREIGN KEY (`users_uid` , `users_provider`)
    REFERENCES `takemelegends`.`users` (`uid` , `provider`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_users_has_achievements_achievements1`
    FOREIGN KEY (`achievements_name`)
    REFERENCES `takemelegends`.`achievements` (`name`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `takemelegends`.`app`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `takemelegends`.`app` ;

CREATE TABLE IF NOT EXISTS `takemelegends`.`app` (
  `appkey` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`appkey`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `takemelegends`.`tokens`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `takemelegends`.`tokens` ;

CREATE TABLE IF NOT EXISTS `takemelegends`.`tokens` (
  `token` VARCHAR(255) NOT NULL,
  `expiration_date` VARCHAR(45) NULL,
  `users_uid` INT NOT NULL,
  `users_provider` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`token`),
  INDEX `fk_tokens_users1_idx` (`users_uid` ASC, `users_provider` ASC),
  CONSTRAINT `fk_tokens_users1`
    FOREIGN KEY (`users_uid` , `users_provider`)
    REFERENCES `takemelegends`.`users` (`uid` , `provider`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
-- begin attached script 'script'
DROP TRIGGER IF EXISTS `increase_number_of_attendances_on_events_table`;
CREATE TRIGGER increase_number_of_attendances_on_events_table
AFTER INSERT ON attendances
FOR EACH ROW
  UPDATE events
     SET number_attendances = number_attendances + 1
   WHERE id = NEW.events_id;

DROP TRIGGER IF EXISTS `decrease_number_of_attendances_on_events_table`;
CREATE TRIGGER decrease_number_of_attendances_on_events_table
AFTER DELETE ON attendances
FOR EACH ROW
 UPDATE events
    SET number_attendances = number_attendances - 1
  WHERE id = OLD.events_id;
-- end attached script 'script'
