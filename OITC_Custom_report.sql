WITH T1 AS
  (SELECT
    /*+ inline */
    *
  FROM
    ( SELECT 'BE' EU_CODE ,'BELGIUM' EU_c FROM DUAL
    UNION ALL
    SELECT 'BG','BULGARIA' FROM DUAL
    UNION ALL
    SELECT 'CZ','CZECH REPUBLIC' FROM DUAL
    UNION ALL
    SELECT 'DK','DENMARK' FROM DUAL
    UNION ALL
    SELECT 'DE','GERMANY' FROM DUAL
    UNION ALL
    SELECT 'EE','ESTONIA' FROM DUAL
    UNION ALL
    SELECT 'IE','IRELAND' FROM DUAL
    UNION ALL
    SELECT 'EL','GREECE' FROM DUAL
    UNION ALL
    SELECT 'ES','SPAIN' FROM DUAL
    UNION ALL
    SELECT 'FR','FRANCE' FROM DUAL
    UNION ALL
    SELECT 'HR','CROATIA' FROM DUAL
    UNION ALL
    SELECT 'IT','ITALY' FROM DUAL
    UNION ALL
    SELECT 'CY','CYPRUS' FROM DUAL
    UNION ALL
    SELECT 'LV','LATVIA' FROM DUAL
    UNION ALL
    SELECT 'LT','LITHUANIA' FROM DUAL
    UNION ALL
    SELECT 'LU','LUXEMBOURG' FROM DUAL
    UNION ALL
    SELECT 'HU','HUNGARY' FROM DUAL
    UNION ALL
    SELECT 'MT','MALTA' FROM DUAL
    UNION ALL
    SELECT 'NL','NETHERLANDS' FROM DUAL
    UNION ALL
    SELECT 'AT','AUSTRIA' FROM DUAL
    UNION ALL
    SELECT 'PL','POLAND' FROM DUAL
    UNION ALL
    SELECT 'PT','PORTUGAL' FROM DUAL
    UNION ALL
    SELECT 'RO','ROMANIA' FROM DUAL
    UNION ALL
    SELECT 'SI','SLOVENIA' FROM DUAL
    UNION ALL
    SELECT 'SK','SLOVAKIA' FROM DUAL
    UNION ALL
    SELECT 'FI','FINLAND' FROM DUAL
    UNION ALL
    SELECT 'SE','SWEDEN' FROM DUAL
    UNION ALL
    SELECT 'UK','UNITED KINGDOM' FROM DUAL
    )
  )
SELECT 
  host_system "Host System",
  calling_system_number "Calling System",
  B.TRANSACTION_TYPE "Transaction Type Code",
  A.MERCHANT "Company Name",
  CASE   
    WHEN    B.SHIP_FROM_COUNTRY='AUSTRALIA' AND A.EXTERNAL_COMPANY_ID='1004140330-1001' 
      THEN    A.EXTERNAL_COMPANY_ID||'AU'
    ELSE    A.EXTERNAL_COMPANY_ID
  END "Entity Code",
  A.MERCHANT_ROLE "Company Role",
  A.FISCAL_DATE "Reporting Date",
  A.INVOICE_DATE "Invoice Date",
  A.TRANSACTION_DATE "Transaction Date",
  A.INVOICE_NUM "Trader Reference",
  A.ORIGINAL_INVOICE_NUM "Credit Note Prior Invoice ID",
  A.ATTRIBUTE_9 "Original Invoice number",
  B.ORIGINAL_INVOICE_DATE "Original Invoice Date",
  A.DOCUMENT_TYPE "Doc Type",
  B.DESCRIPTION "Goods Description",
  B.COMMODITY_CODE "Commodity Code",
  B.PRODUCT_CODE "Product Code",
  B.QUANTITY "Qunatity",
  B.CUSTOMER_NAME "Customer Name",
  B.CUSTOMER_NUMBER "Customer Number",
  B.VENDOR_NAME "Vendor Name",
  B.VENDOR_NUMBER "Vendor Number",
  A.CURRENCY_CODE "Company  Currency",
  nvl(A.ATTRIBUTE_24,1) "Exchange Rate",
 nvl( b.GROSS_AMOUNT,0)  "Net Amount Invoice Currency",
  nvl(C.TAX_DOC_AMOUNT,0) "Tax Amount Invoice Currency",
  B.ATTRIBUTE_38 "Special Config Indicator",
 CASE
   WHEN A.MERCHANT_ROLE='S'
    THEN  ''
    ELSE
      C.SELLER_REG_NUM
   END "Seller Registration",
   CASE
   WHEN A.MERCHANT_ROLE='B' 
     THEN  ''
     ELSE
     C.BUYER_REG_NUM
    END "Buyer Registration",
  B.SHIP_FROM_COUNTRY "SF Country",
(SELECT province FROM rpa_p_002_092.RS_INVOICE_LINE_ADDRESSES WHERE ADDRESS_TYPE='SHIP_FROM' AND INVOICE_LINE_ID = E2.INVOICE_LINE_ID) as  "SF Province",
  B.SHIP_TO_COUNTRY "ST Country",
  (SELECT province FROM rpa_p_002_092.RS_INVOICE_LINE_ADDRESSES WHERE ADDRESS_TYPE='SHIP_TO' AND INVOICE_LINE_ID = E2.INVOICE_LINE_ID) as  "ST Province",
 (SELECT country FROM rpa_p_002_092.RS_INVOICE_LINE_ADDRESSES WHERE ADDRESS_TYPE='SELLER_PRIMARY' AND INVOICE_LINE_ID = E2.INVOICE_LINE_ID) as "Seller Country",
 (SELECT province FROM rpa_p_002_092.RS_INVOICE_LINE_ADDRESSES WHERE ADDRESS_TYPE='SELLER_PRIMARY' AND INVOICE_LINE_ID = E2.INVOICE_LINE_ID) as "Seller Province",
 (SELECT COUNTRY FROM rpa_p_002_092.RS_INVOICE_LINE_ADDRESSES WHERE ADDRESS_TYPE='BUYER_PRIMARY' AND INVOICE_LINE_ID = E3.INVOICE_LINE_ID) as "Buyer Country",
 (SELECT province FROM rpa_p_002_092.RS_INVOICE_LINE_ADDRESSES WHERE ADDRESS_TYPE='BUYER_PRIMARY' AND INVOICE_LINE_ID = E2.INVOICE_LINE_ID) as "Buyer Province",
 (SELECT COUNTRY FROM rpa_p_002_092.RS_INVOICE_LINE_ADDRESSES WHERE ADDRESS_TYPE='SUPPLY' AND INVOICE_LINE_ID = E4.INVOICE_LINE_ID) as "Supplier Country",
 (SELECT province FROM rpa_p_002_092.RS_INVOICE_LINE_ADDRESSES WHERE ADDRESS_TYPE='SUPPLY' AND INVOICE_LINE_ID = E4.INVOICE_LINE_ID) as "Supplier Province",
  B.ATTRIBUTE_22 "Capital Goods Indicator",
  A.ATTRIBUTE_3  "Net Payment Due Date",
  ltrim(B.ATTRIBUTE_42,0) "Standard GL",
 ltrim( B.ATTRIBUTE_13,0)  "Tax GL",
  B.ATTRIBUTE_2  "Material Group",
  B.ATTRIBUTE_3  "Material Name",
  A.ATTRIBUTE_7  "Customer/Vendor Type",
  A.ATTRIBUTE_13 "Sub Contracting Indicator",
  A.ATTRIBUTE_21 "Leasing Indicator",
  A.ATTRIBUTE_23 "Assessable Value",
 CASE WHEN A.DOCUMENT_TYPE!='ZC' OR A.DOCUMENT_TYPE IS NULL
THEN 
CASE WHEN B.ATTRIBUTE_38 IS NULL
THEN
 CASE
        WHEN B.TRANSACTION_TYPE='GS'
          THEN    
          CASE
             WHEN B.SHIP_FROM_COUNTRY = B.SHIP_TO_COUNTRY
                THEN 'D'
              WHEN B.SHIP_FROM_COUNTRY IN
                  (SELECT eu_c FROM T1
                  )
                AND B.SHIP_TO_COUNTRY IN
                  (SELECT eu_c FROM T1
                  )
                THEN 'EU'
           END
        WHEN B.TRANSACTION_TYPE!='GS'
          THEN    
          CASE
              WHEN E2.COUNTRY =E3.COUNTRY
                THEN 'D'
              WHEN E2.COUNTRY IN
                  (SELECT eu_c FROM T1
                  )
                AND E3.COUNTRY IN
                  (SELECT eu_c FROM T1
                  )
                THEN 'EU'
           END
    END
    ||
  CASE
    WHEN C.tax_direction IS NOT NULL
    THEN
      CASE
        WHEN C.tax_type     = 'ZE'
        AND C.tax_direction = 'I'
        THEN 'I_ZEROEXPORT'
        WHEN C.tax_type     = 'ZE'
        AND C.tax_direction = 'O'
        THEN 'O_ZEROEXPORT'
        WHEN C.tax_type     = 'ZI'
        AND C.tax_direction = 'I'
        THEN 'I_ZEROIMPORT'
        WHEN C.tax_type     = 'ZI'
        AND C.tax_direction = 'O'
        THEN 'O_ZEROIMPORT'
        WHEN C.tax_type     = 'VG'
        AND C.tax_direction = 'I'
        THEN 'I_INTRAGROUP'
        WHEN C.tax_type     = 'VG'
        AND C.tax_direction = 'O'
        THEN 'O_INTRAGROUP'
        WHEN C.tax_type     = 'UN'
        AND C.tax_direction = 'I'
        THEN 'I_UNREGISTERED_VENDOR'
        WHEN C.tax_type     = 'UN'
        AND C.tax_direction = 'O'
        THEN 'O_UNREGISTERED_VENDOR'
        WHEN C.tax_type     = 'IC'
        AND C.tax_direction = 'I'
        THEN 'I_INTRACOMPANY'
        WHEN C.tax_type     = 'IC'
        AND C.tax_direction = 'O'
        THEN 'O_INTRACOMPANY'        
       ELSE
       --  ||
         CASE WHEN C.tax_direction IS NULL THEN 
               CASE
                WHEN A.MERCHANT_ROLE = 'B'
                THEN 'I'
                WHEN A.MERCHANT_ROLE ='S' THEN 'O'
                  END
          ELSE
          c.tax_direction
          end 
          ||
          CASE
            WHEN C.tax_type IN ( 'AC', 'RC', 'ER', 'IR', 'IM','NR')
            THEN 'AP'
            WHEN tax_direction = 'I'
            THEN 'AP'
            ELSE 'AR'
          END
          || '_'
          || SUBSTR('-'
          || C.tax_type, 2)
          || B.transaction_type
          || '_'||
          CASE WHEN  B.ATTRIBUTE_22 IN ('P','p') 
               THEN 'P_'
          WHEN  B.ATTRIBUTE_22 IN ('I','i') 
               THEN 'I_'
           END        
          ||
          CASE WHEN  A.ATTRIBUTE_7 IN ('19|Micro Entrepreneur','20|Small') and                                   A.EXTERNAL_COMPANY_ID='1004140330-1030'
               THEN '_C_'
           END
          || C.tax_rate_code
          || TRIM(
          CASE
            WHEN
              CASE
                WHEN C.exempt_flag IS NULL
                THEN ''
                ELSE C.exempt_flag
              END = 'Y'
            THEN 'EX'
            WHEN (C.tax_type    = 'NL'
            OR C.tax_rate_code IN ( 'ZR', 'NL'))
            THEN ''
            ELSE --Cast ( Str(C.tax_rate * 100, 2) AS VARCHAR) END
              TO_CHAR( C.tax_rate * 100,'999.00')
          END )||
          CASE
	  WHEN B.CREDIT_FLAG='Y' and A.EXTERNAL_COMPANY_ID in ('1004140330-1171','1004140330-1090')
	   AND EXTRACT(MONTH FROM (a.FISCAL_DATE)) <> nvl(EXTRACT( MONTH FROM (b.original_invoice_date)),13)
	  THEN '_PTD'
        END
          --||
          --case when B.ATTRIBUTE_7 IS   NULL then
          -- null
           --else
           --'_' || B.ATTRIBUTE_7
           --end
    END
    ELSE 'NO TAX'
  END
   ELSE    B.ATTRIBUTE_38
 END
   ELSE   SUBSTR(C.erp_tax_code,1,2) ||'_' || B.TRANSACTION_TYPE
  END "Tax Classification Code",
  CASE WHEN C.tax_direction IS NULL THEN 
                CASE
                WHEN A.MERCHANT_ROLE = 'B'
                THEN 'I'
                WHEN A.MERCHANT_ROLE ='S' THEN 'O'
                END
          ELSE
          c.tax_direction
  end   "Flow", 
  B.POL || '/'  ||PORT_OF_ENTRY "Port Loading/Unloading",
c.tax_Type "Tax Type",
C.Taxable_Country "Taxable Country",
C.Taxable_State "Taxable State (US)",
c.Taxable_Province	"Taxable Province (non US)",
C.Taxable_County "Taxble County",
C.Taxable_City "Taxble City",
C.Taxable_District  "Taxble District ",
C.Taxable_Postcode  "Taxble Postcode ",
C.Taxable_Geocode "Taxble Geocode",
A.MOST_RECENT "Most Recent",
B.CREDIT_FLAG "Is Credit",
A.IS_REVERSED "Is Reversed",
B.ATTRIBUTE_31 "Mexico Operation Type",
C.ERP_TAX_CODE "ERP Tax Code"

FROM rpa_p_002_092.RS_INVOICES A
INNER JOIN rpa_p_002_092.RS_INVOICE_LINES B
ON A.INVOICE_ID = B.INVOICE_ID
LEFT OUTER JOIN rpa_p_002_092.RS_INVOICE_line_ADDRESSES_ALL E
ON B.INVOICE_LINE_ID = E.INVOICE_LINE_ID
INNER JOIN rpa_p_002_092.RS_INVOICE_line_taxes C
ON B.INVOICE_LINE_ID = C.INVOICE_LINE_ID
INNER JOIN rpa_p_002_092.RS_DATE_DIM D1
ON A.RS_INVOICE_DATE_KEY = D1.DATE_KEY
INNER JOIN rpa_p_002_092.RS_DATE_DIM D2
ON A.RS_FISCAL_DATE_KEY = D2.DATE_KEY
INNER JOIN rpa_p_002_092.RS_DATE_DIM D3
ON A.RS_TRANSACTION_DATE_KEY = D3.DATE_KEY
LEFT JOIN t1 f
ON c.taxable_country = f.eu_code
LEFT JOIN rpa_p_002_092.RS_INVOICE_line_ADDRESSES e2
ON E2.INVOICE_LINE_ID = b.INVOICE_LINE_ID and E2.ADDRESS_TYPE ='SELLER_PRIMARY'
LEFT JOIN rpa_p_002_092.RS_INVOICE_line_ADDRESSES e3
ON E3.INVOICE_LINE_ID = b.INVOICE_LINE_ID and E3.ADDRESS_TYPE='BUYER_PRIMARY'
LEFT JOIN rpa_p_002_092.RS_INVOICE_line_ADDRESSES e4
ON E4.INVOICE_LINE_ID = b.INVOICE_LINE_ID and E3.ADDRESS_TYPE='SUPPLY'
WHERE 1=1
 AND A.MERCHANT in {?Company(s)}
--AND A.MERCHANT <> '1030 Orica Argentina S.A.I.C.'
AND C.TAX_TYPE <> 'CA'
AND A.MOST_RECENT='Y'
AND A.INVOICE_ID IN ( 
		SELECT MAX(AI.INVOICE_ID) 
		  FROM rpa_p_002_092.RS_INVOICES AI 
		 WHERE AI.INVOICE_NUM=A.INVOICE_NUM
		   AND AI.MOST_RECENT=A.MOST_RECENT
		   AND AI.EXTERNAL_COMPANY_ID=A.EXTERNAL_COMPANY_ID)
         AND (    ('D' = '{?Date Type}' AND D1.DAY_DATE >= {?Start Date} AND D1.DAY_DATE <= {?End Date})
               OR ('F' = '{?Date Type}' AND D2.DAY_DATE >= {?Start Date} AND D2.DAY_DATE <= {?End Date})
               OR ('T' = '{?Date Type}' AND D3.DAY_DATE >= {?Start Date} AND d3.DAY_DATE <= {?End Date})

