select *
from PortofolioProject..NashvilleHousing

--Standardize Date Format

select SaleDateConverted , convert(date,SaleDate) as SaleDate
from PortofolioProject..NashvilleHousing

alter table NashvilleHousing
Add SaleDateConverted date; 

update NashvilleHousing
set SaleDateConverted= convert(date,SaleDate)

--Population Property Address
select *
from PortofolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortofolioProject..NashvilleHousing a
join PortofolioProject..NashvilleHousing b
  on a.ParcelID=b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
 -- order by a.ParcelID
where a.PropertyAddress is null
  
update a
set PropertyAddress= isnull(a.PropertyAddress,b.PropertyAddress)
from PortofolioProject..NashvilleHousing a
join PortofolioProject..NashvilleHousing b
  on a.ParcelID=b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking Address into Individual Columns (Address, City, State)
select
substring(PropertyAddress,1, charindex(',',PropertyAddress)-1) as Address
, substring(PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress) ) as City

from PortofolioProject..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update  NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255) 

update  NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress))


-- Split OwnerAddress Using ParceName

select 
 parsename(replace(OwnerAddress,',','.'),3),
  parsename(replace(OwnerAddress,',','.'),2),
   parsename(replace(OwnerAddress,',','.'),1)
from PortofolioProject..NashvilleHousing
where OwnerAddress is not null


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255) 

update  NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255) 

update  NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255) 

update  NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1)


--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortofolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from PortofolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case 
       when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

--Remove Duplicates using row_number & cte 
with RowNumCTE as (
Select *,
row_number() over (
partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by
			  UniqueID
			  ) row_num

from PortofolioProject..NashvilleHousing
)

delete
from RowNumCTE
where row_num>1


--Delete Some Unused Columns
alter table PortofolioProject..NashvilleHousing
drop column  OwnerAddress, TaxDistrict, PropertyAddress,SaleDate 

select *
from PortofolioProject..NashvilleHousing