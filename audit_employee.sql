-- audit table to control employee title changes
CREATE TABLE employees_auditoria (
	employee_id INT,
	old_name VARCHAR(100),
	new_name VARCHAR(100),
	changed_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- stored procedure for changing the title of employees
CREATE OR REPLACE PROCEDURE update_employee_title (
	p_employee_id INT,
	p_new_title VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE employees
	SET title = p_new_title
	WHERE employee_id = p_employee_id;
END;
$$;

-- function to insert the changes in the audit table 
CREATE OR REPLACE FUNCTION func_check_employee_title()
RETURNS TRIGGER AS $$
BEGIN
	INSERT INTO employees_auditoria (employee_id, old_name, new_name)
	VALUES (NEW.employee_id, OLD.title, NEW.title);
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- trigger to run the function if a title is changed
CREATE TRIGGER trg_check_new_name
AFTER UPDATE OF title ON employees
FOR EACH ROW
EXECUTE FUNCTION func_check_employee_title();