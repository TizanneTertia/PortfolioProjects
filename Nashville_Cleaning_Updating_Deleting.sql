
SELECT *
FROM PortFolioProject1.dbo.NashvilleHousingDataCleaning

--Standardize date format

SELECT SaleDateConverted, CONVERT (Date,SaleDate)
FROM PortFolioProject1.dbo.NashvilleHousingDataCleaning

UPDATE NashvilleHousingDataCleaning
SET SaleDate = CONVERT (Date,SaleDate)

ALTER TABLE NashvilleHousingDataCleaning
Add SaleDateConverted Date;

UPDATE NashvilleHousingDataCleaning
SET SaleDateConverted = CONVERT (Date,SaleDate)

--Populate Property Address date

SELECT *
FROM PortFolioProject1.dbo.NashvilleHousingDataCleaning
--WHERE PropertyAddress is Null
order by ParcelID


SELECT Part_A.ParcelID,Part_A.PropertyAddress,Part_B.ParcelID,Part_B.PropertyAddress, ISNULL (Part_A.PropertyAddress,Part_B.PropertyAddress)
FROM PortFolioProject1.dbo.NashvilleHousingDataCleaning Part_A
JOIN PortFolioProject1.dbo.NashvilleHousingDataCleaning Part_B
ON Part_A.ParcelID = Part_B.ParcelID
AND Part_A.[UniqueID ] <> Part_B.[UniqueID ]
WHERE Part_A.PropertyAddress is null


UPDATE Part_A
SET PropertyAddress = ISNULL (Part_A.PropertyAddress,Part_B.PropertyAddress)
FROM PortFolioProject1.dbo.NashvilleHousingDataCleaning Part_A
JOIN PortFolioProject1.dbo.NashvilleHousingDataCleaning Part_B
ON Part_A.ParcelID = Part_B.ParcelID
AND Part_A.[UniqueID ] <> Part_B.[UniqueID ]
WHERE Part_A.PropertyAddress is null


--breaking out Address into Individual Columns (Address, State , City)


SELECT PropertyAddress
FROM PortFolioProject1.dbo.NashvilleHousingDataCleaning

SELECT 
SUBSTRING(PropertyAddress,1, CHARINDEX (',',PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress))AS Address
FROM PortFolioProject1.dbo.NashvilleHousingDataCleaning


ALTER TABLE NashvilleHousingDataCleaning
Add PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousingDataCleaning
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX (',',PropertyAddress)-1)

ALTER TABLE NashvilleHousingDataCleaning
Add PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousingDataCleaning
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress))



SELECT OwnerAddress
FROM PortFolioProject1.dbo.NashvilleHousingDataCleaning

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortFolioProject1.dbo.NashvilleHousingDataCleaning

ALTER TABLE NashvilleHousingDataCleaning
Add OwnerSplitAddres NVARCHAR(255);

UPDATE NashvilleHousingDataCleaning
SET OwnerSplitAddres = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousingDataCleaning
Add OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousingDataCleaning
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousingDataCleaning
Add OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousingDataCleaning
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortFolioProject1.dbo.NashvilleHousingDataCleaning
GROUP BY SoldAsVacant
ORDER  BY 2


SELECT SoldAsVacant
,Case WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortFolioProject1.dbo.NashvilleHousingDataCleaning

UPDATE NashvilleHousingDataCleaning
SET SoldAsVacant = Case WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortFolioProject1.dbo.NashvilleHousingDataCleaning

--Remove Duplicates 
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY 
		UniqueID
		) row_num
FROM PortFolioProject1.dbo.NashvilleHousingDataCleaning
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


--DELETE UNUSED COLUMNS

SELECT *
FROM PortFolioProject1.dbo.NashvilleHousingDataCleaning

ALTER TABLE PortFolioProject1.dbo.NashvilleHousingDataCleaning
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE PortFolioProject1.dbo.NashvilleHousingDataCleaning
DROP COLUMN SaleDate