USE DATABASE <%wideworldimportersdw%>;

CREATE OR REPLACE PROCEDURE Sequences.ReseedAllSequences ()
RETURNS VARCHAR
LANGUAGE SQL
COMMENT = '{ "origin": "sf_sc", "name": "snowconvert", "version": {  "major": 2,  "minor": 51,  "patch": "3" }, "attributes": {  "component": "transact",  "convertedOn": "10/24/2026",  "domain": "no-domain-provided",  "migrationid": "b2+hARmCqXWV01MqpcnF4w==" }}'
EXECUTE AS CALLER
AS
$$
    BEGIN
--        -- Ensures that the next sequence values are above the maximum value of the related table columns
--        --** SSC-FDM-TS0029 - SET NOCOUNT STATEMENT IS COMMENTED OUT, WHICH IS NOT APPLICABLE IN SNOWFLAKE. **
--        SET NOCOUNT ON;
        CALL Sequences.ReseedSequenceBeyondTableValues('CityKey', 'Dimension', 'City', 'City Key');
        CALL Sequences.ReseedSequenceBeyondTableValues('CustomerKey', 'Dimension', 'Customer', 'Customer Key');
        CALL Sequences.ReseedSequenceBeyondTableValues('EmployeeKey', 'Dimension', 'Employee', 'Employee Key');
        CALL Sequences.ReseedSequenceBeyondTableValues('LineageKey', 'Integration', 'Lineage', 'Lineage Key');
        CALL Sequences.ReseedSequenceBeyondTableValues('PaymentMethodKey', 'Dimension', 'Payment Method', 'Payment Method Key');
        CALL Sequences.ReseedSequenceBeyondTableValues('StockItemKey', 'Dimension', 'Stock Item', 'Stock Item Key');
        CALL Sequences.ReseedSequenceBeyondTableValues('SupplierKey', 'Dimension', 'Supplier', 'Supplier Key');
        CALL Sequences.ReseedSequenceBeyondTableValues('TransactionTypeKey', 'Dimension', 'Transaction Type', 'Transaction Type Key');
    END;
$$;