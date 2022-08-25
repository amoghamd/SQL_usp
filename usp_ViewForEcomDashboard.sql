USE dw
GO
/*
            jira          : XXXX
            create date   : April 28, 2022
            create by     : AMD
            description   : view to used in Ecomm_Dashboard based on order_header_view_staging
            
*/


CREATE OR ALTER VIEW order_by_status_vw
AS
SELECT 
            warehouse_id
            ,owner_id
            ,client_id
            ,ops_order_status_name
            ,COUNT(1) order_count
            ,SUM(qty_total) units
FROM order_header_view
WHERE 1                              =          1
AND
            ops_order_status_name in ('Assigned to Batch'
                                       ,'Processing'
                                       ,'Picked Pre Wall'
                                       ,'Picked Waiting to Ship'
                                       ,'Shipping'
                                                                                    )

GROUP BY    warehouse_id
                                    ,owner_id
                                    ,client_id
                                    ,ops_order_status_name

--------------------------------------------------------------------------------------------------------------

USE dw
GO

SET ANSI_NULLS ON
GO
/*
            jira                  : XXXX
            create date           : April 28, 2022
            create by             : AMD
            description           : view based on order_header_view used in Ecomm_Dashboard
*/        
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW dbo.batch_pending_to_ship_vw
AS
SELECT           warehouse_id
                        ,owner_id
                        ,client_id
                        ,CASE WHEN batch_variation_pick_type_name = 'Pick&Put' THEN SUBSTRING(batch,1,4) 
                          WHEN batch_variation_pick_type_name = 'Individual Variation' THEN 'Variations' 
                          WHEN batch_variation_pick_type_name IS NULL THEN 'Processing' 
                          ELSE 'Pack To Light' 
                          END batch_type 
                        , count(*)  order_count 
FROM order_header_view
WHERE          1                      =          1
AND                sla_order_type_key           IN        (6,11) --  Regular Ecom, Same Day
AND                sla_date_current    =          convert(date,getdate()) 
GROUP BY
                        warehouse_id
                        ,owner_id
                        ,client_id
                        ,CASE WHEN batch_variation_pick_type_name = 'Pick&Put' THEN SUBSTRING(batch,1,4) 
                          WHEN batch_variation_pick_type_name = 'Individual Variation' THEN 'Variations' 
                          WHEN batch_variation_pick_type_name IS NULL THEN 'Processing' 
                          ELSE 'Pack To Light' 
                          END 
GO
