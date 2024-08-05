-- Create materialized view to see monthly accumulated sales
CREATE MATERIALIZED VIEW accumulated_monthly_sales_mv AS 
    SELECT
        EXTRACT(YEAR FROM o.order_date) AS year,
        EXTRACT(MONTH FROM o.order_date) AS month,
        SUM((od.unit_price * od.quantity) * (1-od.discount)) AS accumulated_sales
    FROM 
        order_details AS od
    INNER JOIN 
        orders AS o
    ON
        o.order_id = od.order_id
    GROUP BY
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date)
    ORDER BY
        EXTRACT(YEAR FROM o.order_date),
        EXTRACT(MONTH FROM o.order_date);

-- Function creation to refresh the materialized view
CREATE OR REPLACE FUNCTION func_refresh_accumulated_monthly_sales_mv() 
RETURNS TRIGGER AS $$
BEGIN
    REFRESH MATERIALIZED VIEW accumulated_monthly_sales_mv; 
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger creation for the table orders
CREATE TRIGGER trg_refresh_accumulated_monthly_sales_mv_orders
AFTER INSERT OR UPDATE OR DELETE ON orders
FOR EACH STATEMENT
EXECUTE FUNCTION func_refresh_accumulated_monthly_sales_mv();

-- Trigger creation for the table order_details
CREATE TRIGGER trg_refresh_accumulated_monthly_sales_mv_order_details
AFTER INSERT OR UPDATE OR DELETE ON order_details
FOR EACH STATEMENT
EXECUTE FUNCTION func_refresh_accumulated_monthly_sales_mv();