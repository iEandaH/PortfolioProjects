
Select *
from PortfolioProjects.[dbo].[NashvilleHousing]

-------------------------------------------------------------------
----------Standardize Date Format----------------------------------
Select SaleDate, Convert(Date, SaleDate) 
from PortfolioProjects.[dbo].[NashvilleHousing]

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update [NashvilleHousing]
set SaleDateConverted = Convert(Date, SaleDate)

--------------------------------------------------------------------------
----------Populate Property Address Data----------------------------------
Select *
--Select PropertyAddress
from PortfolioProjects.[dbo].[NashvilleHousing]
--where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects.[dbo].[NashvilleHousing] a
join PortfolioProjects.[dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	and a.uniqueID <> b.uniqueID
where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects.[dbo].[NashvilleHousing] a
join PortfolioProjects.[dbo].[NashvilleHousing] b
	on a.ParcelID = b.ParcelID
	and a.uniqueID <> b.uniqueID
where a.PropertyAddress is null


----------------------------------------------------------------------------------
--Breaking out Address into Individual Columns (Address, City, State)-------------
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
from PortfolioProjects.dbo.NashvilleHousing


Alter Table PortfolioProjects.dbo.NashvilleHousing
Add PropertyAddressSplit Nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
set PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


Alter Table PortfolioProjects.dbo.NashvilleHousing
Add PropertyCity Nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
set PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--for Owner Address
Select OwnerAddress
from PortfolioProjects.dbo.NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress, ',','.'),3) as OwnerAddress,
PARSENAME(Replace(OwnerAddress, ',','.'),2) as OwnerCity,
PARSENAME(Replace(OwnerAddress, ',','.'),1) as OwnerState
from PortfolioProjects.dbo.NashvilleHousing


Alter Table PortfolioProjects.dbo.NashvilleHousing
Add OwnerAddress Nvarchar(255);

Alter Table PortfolioProjects.dbo.NashvilleHousing
Add OwnerCity Nvarchar(255);

Alter Table PortfolioProjects.dbo.NashvilleHousing
Add OwnerState Nvarchar(255);

Update PortfolioProjects.dbo.NashvilleHousing
set OwnerAddress = PARSENAME(Replace(OwnerAddress, ',','.'),3)

Update PortfolioProjects.dbo.NashvilleHousing
set OwnerCity = PARSENAME(Replace(OwnerAddress, ',','.'),2)

Update PortfolioProjects.dbo.NashvilleHousing
set OwnerState = PARSENAME(Replace(OwnerAddress, ',','.'),1)


---------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant Field" ---------------

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProjects.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
Case when SoldAsVacant ='Y' then 'Yes'
	 when SoldAsVacant ='N' then 'No'
	 Else SoldAsVacant
	 End
from PortfolioProjects.dbo.NashvilleHousing


Update PortfolioProjects.dbo.NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant ='Y' then 'Yes'
					 when SoldAsVacant ='N' then 'No'
						Else SoldAsVacant
						End


--------------------------------------------------------------------------------
--Remove Duplicates ------------------------------------------------------------
With RowNumCTE as(

Select *,
		ROW_NUMBER() OVER (
		PARTITION by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 Order By
					 UniqueID
					 ) row_num
from PortfolioProjects.dbo.NashvilleHousing
)
Select *
--Delete 
from RowNumCTE
where row_num>1
--Order by PropertyAddress



--------------------------------------------------------------------------------------
-- Delete Unused Columns ------------------------------------------------------------
Alter Table PortfolioProjects.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
from PortfolioProjects.dbo.NashvilleHousing
