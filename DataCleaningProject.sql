--Cleaning Data

Select *
From [dbo].[Nashville Housing]


-- Standardize Date Format

Alter table [dbo].[Nashville Housing]
Add Salesdateconverted Date

Update [dbo].[Nashville Housing]
SET SalesDateConverted = CONVERT(Date,SaleDate)

select * 
From [dbo].[Nashville Housing] 

-- Populate Property Address data

Select *
From [dbo].[Nashville Housing]
Where PropertyAddress is null

Select *
From [dbo].[Nashville Housing]
Where PropertyAddress is null
Order by ParcelID

--Checking for null values in propertyaddress

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
From [dbo].[Nashville Housing] a
Join [dbo].[Nashville Housing] b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

--Replacing Null property Address

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.propertyaddress,b.PropertyAddress)
From [dbo].[Nashville Housing] a
Join [dbo].[Nashville Housing] b
On a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [dbo].[Nashville Housing] a
JOIN [dbo].[Nashville Housing] b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From [dbo].[Nashville Housing]

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From [dbo].[Nashville Housing]

ALTER TABLE [dbo].[Nashville Housing]
Add PropertySplitAddress Nvarchar(255);

Update [dbo].[Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE [dbo].[Nashville Housing]
Add PropertySplitCity Nvarchar(255);

Update [dbo].[Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From [dbo].[Nashville Housing]

Select OwnerAddress
From [dbo].[Nashville Housing]


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From [dbo].[Nashville Housing]

ALTER TABLE [dbo].[Nashville Housing]
Add OwnerSplitAddress Nvarchar(255);

Update [dbo].[Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [dbo].[Nashville Housing]
Add OwnerSplitCity Nvarchar(255);

Update [dbo].[Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE [dbo].[Nashville Housing]
Add OwnerSplitState Nvarchar(255);

Update [dbo].[Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select * 
From [dbo].[Nashville Housing]

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From [dbo].[Nashville Housing]

Update [dbo].[Nashville Housing]
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

Select *
From [dbo].[Nashville Housing]

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From [dbo].[Nashville Housing]
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From [dbo].[Nashville Housing]


-- Delete Unused Columns

ALTER TABLE [dbo].[Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From [dbo].[Nashville Housing]

-- Checking all the null values in all columns

SELECT 
    SUM(CASE WHEN [UniqueID ] IS NULL THEN 1 ELSE 0 END) AS UniqueID_nulls,
    SUM(CASE WHEN [ParcelID] IS NULL THEN 1 ELSE 0 END) AS ParcelID_nulls,
    SUM(CASE WHEN [OwnerName] IS NULL THEN 1 ELSE 0 END) AS OwnerName_nulls,
    SUM(CASE WHEN [LandValue] IS NULL THEN 1 ELSE 0 END) AS LandValue_nulls,
    SUM(CASE WHEN  [BuildingValue] IS NULL THEN 1 ELSE 0 END) AS BuildingName_nulls,
    SUM(CASE WHEN [TotalValue] IS NULL THEN 1 ELSE 0 END) AS TotalValue_nulls,
	SUM(CASE WHEN [YearBuilt] IS NULL THEN 1 ELSE 0 END) AS YearBuilt_nulls,
    SUM(CASE WHEN  [Bedrooms] IS NULL THEN 1 ELSE 0 END) AS Bedroom_nulls,
    SUM(CASE WHEN [FullBath] IS NULL THEN 1 ELSE 0 END) AS FullBath_nulls,
    SUM(CASE WHEN [HalfBath] IS NULL THEN 1 ELSE 0 END) AS HalfBath_nulls,
	Sum(CASE WHEN [Acreage] IS NULL THEN 1 ELSE 0 END) AS Acreage_nulls
From [dbo].[Nashville Housing];

--Replacing null values in specific columns

UPDATE [dbo].[Nashville Housing]
SET FullBath = 1
WHERE FullBath IS NULL AND HalfBath = 0;


UPDATE [dbo].[Nashville Housing]
SET HalfBath = 1
WHERE HalfBath IS NULL AND FullBath = 0;

UPDATE [dbo].[Nashville Housing]
SET 
   [FullBath] = ISNULL([FullBath], 0),
   [HalfBath]  = ISNULL([HalfBath], 0)
WHERE 
    FullBath IS NULL 
    OR HalfBath IS NULL


--Replacing bedrooms nulls with 0

UPDATE [dbo].[Nashville Housing]
SET Bedrooms = ISNULL(Bedrooms,0)
WHERE Bedrooms IS NULL;


-- Finding Bedroom ratio


SELECT [UniqueID], [OwnerName], [Bedrooms], [FullBath], [HalfBath],
       ([Bedrooms] + [FullBath] + [HalfBath]) AS [TotalRooms]
FROM [dbo].[Nashville Housing];


ALTER TABLE [dbo].[Nashville Housing]
ADD TotalRooms INT;

Update [dbo].[Nashville Housing]
Set TotalRooms = bedrooms+fullbath+halfbath 

--Replacing null values with 0 in totalrooms

UPDATE [dbo].[Nashville Housing]
SET TotalRooms = ISNULL(TotalRooms, 0);

SELECT [UniqueID], [OwnerName], 
       [Bedrooms]/NULLIF([TotalRooms], 0) AS [BedroomRatio]
FROM [dbo].[Nashville Housing];

-- Removing Outliners

DELETE FROM [dbo].[Nashville Housing]
WHERE LandValue > 10000000;


-- Replace null values in LandValue, BuildingValue, and TotalValue with 0


UPDATE [dbo].[Nashville Housing]
SET 
    LandValue = ISNULL(LandValue, 0),
    BuildingValue = ISNULL(BuildingValue, 0),
    TotalValue = ISNULL(TotalValue, 0)
WHERE 
    LandValue IS NULL 
    OR BuildingValue IS NULL 
    OR TotalValue IS NULL;


--Filling missing values in the yearbuilt column

UPDATE [dbo].[Nashville Housing]
SET YearBuilt = (
  SELECT COALESCE(AVG(YearBuilt), 0)
  FROM [dbo].[Nashville Housing] AS nh2
  WHERE nh2.OwnerName = [dbo].[Nashville Housing].OwnerName
)
WHERE YearBuilt IS NULL;


Select *
From [dbo].[Nashville Housing]

--Binning the LandValue

SELECT *,
    CASE
        WHEN [LandValue] < 100000 THEN 'Low'
        WHEN [LandValue] >= 100000 AND [LandValue] < 200000 THEN 'Medium'
        ELSE 'High'
    END AS [LandValue_bin]
FROM [dbo].[Nashville Housing]

