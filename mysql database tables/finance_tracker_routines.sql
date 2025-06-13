-- MySQL dump 10.13  Distrib 8.0.38, for macos14 (x86_64)
--
-- Host: localhost    Database: finance_tracker
-- ------------------------------------------------------
-- Server version	9.0.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Temporary view structure for view `user_goals_advisor`
--

DROP TABLE IF EXISTS `user_goals_advisor`;
/*!50001 DROP VIEW IF EXISTS `user_goals_advisor`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `user_goals_advisor` AS SELECT 
 1 AS `goal_id`,
 1 AS `user_id`,
 1 AS `fullname`,
 1 AS `goal_name`,
 1 AS `goal_amount`,
 1 AS `saved_amount`,
 1 AS `status`,
 1 AS `created_at`,
 1 AS `updated_at`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `user_income_expenses`
--

DROP TABLE IF EXISTS `user_income_expenses`;
/*!50001 DROP VIEW IF EXISTS `user_income_expenses`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `user_income_expenses` AS SELECT 
 1 AS `user_id`,
 1 AS `username`,
 1 AS `income_amount`,
 1 AS `income_date`,
 1 AS `expense_amount`,
 1 AS `expense_date`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `user_financial_summary`
--

DROP TABLE IF EXISTS `user_financial_summary`;
/*!50001 DROP VIEW IF EXISTS `user_financial_summary`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `user_financial_summary` AS SELECT 
 1 AS `user_id`,
 1 AS `username`,
 1 AS `total_income`,
 1 AS `total_expenses`,
 1 AS `net_balance`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `user_individual_transactions`
--

DROP TABLE IF EXISTS `user_individual_transactions`;
/*!50001 DROP VIEW IF EXISTS `user_individual_transactions`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `user_individual_transactions` AS SELECT 
 1 AS `user_id`,
 1 AS `fullname`,
 1 AS `amount`,
 1 AS `category`,
 1 AS `type`,
 1 AS `transaction_date`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `income_expenses_amount`
--

DROP TABLE IF EXISTS `income_expenses_amount`;
/*!50001 DROP VIEW IF EXISTS `income_expenses_amount`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `income_expenses_amount` AS SELECT 
 1 AS `user_id`,
 1 AS `total_income`,
 1 AS `total_expenses`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `user_goals_advisor`
--

/*!50001 DROP VIEW IF EXISTS `user_goals_advisor`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `user_goals_advisor` AS select `ug`.`goal_id` AS `goal_id`,`ug`.`user_id` AS `user_id`,`u`.`fullname` AS `fullname`,`ug`.`goal_name` AS `goal_name`,`ug`.`goal_amount` AS `goal_amount`,`ug`.`saved_amount` AS `saved_amount`,`ug`.`status` AS `status`,`ug`.`created_at` AS `created_at`,`ug`.`updated_at` AS `updated_at` from (`user_goals` `ug` join `users` `u` on((`ug`.`user_id` = `u`.`user_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `user_income_expenses`
--

/*!50001 DROP VIEW IF EXISTS `user_income_expenses`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `user_income_expenses` AS select `u`.`user_id` AS `user_id`,`u`.`username` AS `username`,`i`.`income_amount` AS `income_amount`,`i`.`income_date` AS `income_date`,`e`.`amount` AS `expense_amount`,`e`.`expense_date` AS `expense_date` from ((`users` `u` left join `income` `i` on((`u`.`user_id` = `i`.`user_id`))) left join `expenses` `e` on((`u`.`user_id` = `e`.`user_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `user_financial_summary`
--

/*!50001 DROP VIEW IF EXISTS `user_financial_summary`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `user_financial_summary` AS select `u`.`user_id` AS `user_id`,`u`.`fullname` AS `username`,coalesce(`income_totals`.`total_income`,0) AS `total_income`,coalesce(`expense_totals`.`total_expenses`,0) AS `total_expenses`,(coalesce(`income_totals`.`total_income`,0) - coalesce(`expense_totals`.`total_expenses`,0)) AS `net_balance` from ((`users` `u` left join (select `income`.`user_id` AS `user_id`,sum(`income`.`income_amount`) AS `total_income` from `income` group by `income`.`user_id`) `income_totals` on((`u`.`user_id` = `income_totals`.`user_id`))) left join (select `expenses`.`user_id` AS `user_id`,sum(`expenses`.`amount`) AS `total_expenses` from `expenses` group by `expenses`.`user_id`) `expense_totals` on((`u`.`user_id` = `expense_totals`.`user_id`))) order by `u`.`user_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `user_individual_transactions`
--

/*!50001 DROP VIEW IF EXISTS `user_individual_transactions`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `user_individual_transactions` AS select `u`.`user_id` AS `user_id`,`u`.`fullname` AS `fullname`,`i`.`income_amount` AS `amount`,`i`.`income_subcategory` AS `category`,'Income' AS `type`,`i`.`income_date` AS `transaction_date` from (`users` `u` join `income` `i` on((`u`.`user_id` = `i`.`user_id`))) union all select `u`.`user_id` AS `user_id`,`u`.`fullname` AS `fullname`,`e`.`amount` AS `amount`,`e`.`category` AS `category`,'Expense' AS `type`,`e`.`expense_date` AS `transaction_date` from (`users` `u` join `expenses` `e` on((`u`.`user_id` = `e`.`user_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `income_expenses_amount`
--

/*!50001 DROP VIEW IF EXISTS `income_expenses_amount`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `income_expenses_amount` AS select `u`.`user_id` AS `user_id`,coalesce(sum(`i`.`income_amount`),0) AS `total_income`,coalesce(sum(`e`.`amount`),0) AS `total_expenses` from ((`users` `u` left join `income` `i` on((`u`.`user_id` = `i`.`user_id`))) left join `expenses` `e` on((`u`.`user_id` = `e`.`user_id`))) group by `u`.`user_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-11-28 20:05:18
