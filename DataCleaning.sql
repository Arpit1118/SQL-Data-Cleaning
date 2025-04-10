/*

Cleaning Data in SQL Queries

*/
Select *
From Portfolio.dbo.NashvilleHousing
---------------------------------------------------------------------------------------------------------------------------------------------------------

--Standardize Date Format

Select SaleDateConverted,CONVERT(Date,SaleDate)
From Portfolio.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate=CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted=CONVERT(Date,SaleDate)

-------------------------------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data

Select *
From Portfolio.dbo.NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID


Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio.dbo.NashvilleHousing a
Join Portfolio.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is NULL

Update a
set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
From Portfolio.dbo.NashvilleHousing a
Join Portfolio.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is NULL

----------------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking Out Address into Individual Columns(Address,City,State)

Select PropertyAddress
From Portfolio.dbo.NashvilleHousing
--where PropertyAddress is NULL
--order by ParcelID

Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress)) as Address
From Portfolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(250);

Update NashvilleHousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(250);

Update NashvilleHousing
SET PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress))

Select *
From Portfolio.dbo.NashvilleHousing






Select OwnerAddress
From Portfolio.dbo.NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress,',','.'),3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
From Portfolio.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(250);

Update NashvilleHousing
SET OwnerSplitAddress=PARSENAME(Replace(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(250);

Update NashvilleHousing
SET OwnerSplitCity=PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(250);

Update NashvilleHousing
SET OwnerSplitState=PARSENAME(Replace(OwnerAddress,',','.'),1)

Select *
From Portfolio.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" Field

select Distinct(SoldAsVacant), count(SoldAsVacant)
From Portfolio.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
,Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	END
From Portfolio.dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant=Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	END

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates
with RowNumCTE As(
Select * ,
ROW_NUMBER()Over(
Partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
Order by UniqueID) row_num

From Portfolio.dbo.NashvilleHousing
--order by ParcelID
)


Delete
From RowNumCTE
where row_num>1
--Order by PropertyAddress

Select *
From Portfolio.dbo.NashvilleHousing

-------------------------------------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

Select *
From Portfolio.dbo.NashvilleHousing

Alter Table Portfolio.dbo.NashvilleHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress

Alter Table Portfolio.dbo.NashvilleHousing
Drop Column SaleDate