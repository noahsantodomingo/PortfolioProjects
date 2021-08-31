/* 

Cleaning Data in SQL queries 

*/


SELECT * 
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------


-- Standardize Date Format 

SELECT SaleDateConverted, CONVERT(DATE, SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE,SaleDate)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted DATE 

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)

-------------------------------------------------------------------------------------------------


-- Populate Property Address data 

SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
  WHERE a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
  on a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]

-------------------------------------------------------------------------------------------------


-- Breaking out Address into individual columns (Address, City, State) 

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));



-- Seperate Owner Address


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);




-------------------------------------------------------------------------------------------------



--Change Y and N to Yes and No in "Sold as Vacant" field 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant, 
  CASE WHEN SoldAsVacant = 'y' THEN 'Yes'
	   WHEN SoldAsVacant = 'n' THEN 'No' 
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'y' THEN 'Yes'
	   WHEN SoldAsVacant = 'n' THEN 'No' 
	   ELSE SoldAsVacant
	   END




-------------------------------------------------------------------------------------------------

-- Remove Duplicates

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
				) AS row_num
			
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1 


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
				) AS row_num
			
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)

select * 
FROM RowNumCTE
WHERE row_num > 1 
ORDER BY PropertyAddress





-------------------------------------------------------------------------------------------------

-- Delete Unused Columns 

SELECT * 
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

