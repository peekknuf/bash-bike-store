-- MySQL Script generated by MySQL Workbench
-- Thu Sep 21 18:12:34 2023
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema bikes
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `bikes` ;

-- -----------------------------------------------------
-- Schema bikes
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `bikes` DEFAULT CHARACTER SET utf8 ;
USE `bikes` ;

-- -----------------------------------------------------
-- Table `bikes`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `bikes` ;

CREATE TABLE IF NOT EXISTS `bikes` (
  `bike_id` INT NOT NULL AUTO_INCREMENT,
  `type` VARCHAR(50) NOT NULL,
  `size` INT NOT NULL,
  `available` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`bike_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `customers`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `customers` ;

CREATE TABLE IF NOT EXISTS `customers` (
  `customer_id` INT NOT NULL AUTO_INCREMENT,
  `phone` VARCHAR(15) NOT NULL,
  `name` VARCHAR(40) NOT NULL,
  PRIMARY KEY (`customer_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `rentals`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `rentals` ;

CREATE TABLE IF NOT EXISTS `rentals` (
  `rental_id` INT NOT NULL AUTO_INCREMENT,
  `customer_id` INT NOT NULL,
  `bike_id` INT NOT NULL,
  `date_rented` DATETIME NOT NULL DEFAULT NOW(),
  `date_returned` DATETIME NOT NULL,
  PRIMARY KEY (`rental_id`),
  INDEX `bike_id_idx` (`bike_id` ASC) VISIBLE,
  INDEX `customer_id_idx` (`customer_id` ASC) VISIBLE,
  CONSTRAINT `customer_id`
    FOREIGN KEY (`customer_id`)
    REFERENCES `customers` (`customer_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `bike_id`
    FOREIGN KEY (`bike_id`)
    REFERENCES `bikes` (`bike_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
