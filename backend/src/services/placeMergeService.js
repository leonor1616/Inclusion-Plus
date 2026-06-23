function normalizeText(value) {
    return String(value || '')
        .toLowerCase()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .replace(/[^\w\s]/g, '')
        .trim();
}

function normalizeCategory(category) {
    return String(category || '')
        .toLowerCase()
        .trim();
}

// Some transport points can be very close and similarly named, but should stay
// separate because they represent distinct stops/stations.
function isNonMergeableCategory(category) {
    const nonMergeableCategories = [
        'subway_station',
        'train_station',
        'bus_stop',
        'transit_station'
    ];

    return nonMergeableCategories.includes(
        normalizeCategory(category)
    );
}

function areCategoriesCompatible(categoryA, categoryB) {
    const a = normalizeCategory(categoryA);
    const b = normalizeCategory(categoryB);

    if (!a || !b) {
        return false;
    }

    if (a === b) {
        return true;
    }

    const equivalentGroups = [
        ['restaurant', 'bar', 'cafe', 'coffee', 'pastry_shop'],
        ['university', 'school'],
        ['hospital', 'health'],
        ['supermarket', 'grocery_store', 'discount_store'],
        ['library', 'book_store']
    ];

    return equivalentGroups.some(
        (group) => group.includes(a) && group.includes(b)
    );
}

function getDistanceMeters(placeA, placeB) {
    const lat1 = Number(placeA.latitude);
    const lon1 = Number(placeA.longitude);
    const lat2 = Number(placeB.latitude);
    const lon2 = Number(placeB.longitude);

    const R = 6371000;
    const toRad = (value) => (value * Math.PI) / 180;

    const dLat = toRad(lat2 - lat1);
    const dLon = toRad(lon2 - lon1);

    const a =
        Math.sin(dLat / 2) ** 2 +
        Math.cos(toRad(lat1)) *
            Math.cos(toRad(lat2)) *
            Math.sin(dLon / 2) ** 2;

    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function hasAccessibilityInfo(place) {
    return (
        place.raw_accessibility_data &&
        Object.keys(place.raw_accessibility_data).length > 0
    );
}

function areNamesCompatible(nameAValue, nameBValue) {
    const nameA = normalizeText(nameAValue);
    const nameB = normalizeText(nameBValue);

    if (!nameA || !nameB) {
        return false;
    }

    if (nameA === 'unnamed location' || nameB === 'unnamed location') {
        return false;
    }

    return (
        nameA === nameB ||
        nameA.includes(nameB) ||
        nameB.includes(nameA)
    );
}

function arePossibleDuplicates(placeA, placeB) {
    if (
        !placeA.latitude ||
        !placeA.longitude ||
        !placeB.latitude ||
        !placeB.longitude
    ) {
        return false;
    }

    if (
        isNonMergeableCategory(placeA.category) ||
        isNonMergeableCategory(placeB.category)
    ) {
        return false;
    }

    if (!areCategoriesCompatible(placeA.category, placeB.category)) {
        return false;
    }

    if (!areNamesCompatible(placeA.name, placeB.name)) {
        return false;
    }

    const distance = getDistanceMeters(placeA, placeB);

    // A strict distance threshold reduces false merges between nearby venues.
    return distance <= 50;
}

function mergePlaces(primary, secondary) {
    const primaryHasAccessibility = hasAccessibilityInfo(primary);
    const secondaryHasAccessibility = hasAccessibilityInfo(secondary);

    let base = primary;
    let extra = secondary;

    if (!primaryHasAccessibility && secondaryHasAccessibility) {
        // Prefer the record carrying accessibility metadata, because the mobile
        // UI derives tags and AI context from this payload.
        base = secondary;
        extra = primary;
    }

    return {
        ...base,

        name:
            base.name && base.name !== 'Unnamed location'
                ? base.name
                : extra.name,

        category: base.category || extra.category || null,

        source_url: base.source_url || extra.source_url || null,

        raw_accessibility_data:
            base.raw_accessibility_data ||
            extra.raw_accessibility_data ||
            null,

        merged_sources: Array.from(
            new Set([
                base.source,
                extra.source,
                ...(base.merged_sources || []),
                ...(extra.merged_sources || [])
            ].filter(Boolean))
        )
    };
}

function mergeAndDeduplicatePlaces(places) {
    const mergedPlaces = [];

    for (const place of places) {
        const duplicateIndex = mergedPlaces.findIndex((existingPlace) =>
            arePossibleDuplicates(existingPlace, place)
        );

        if (duplicateIndex === -1) {
            mergedPlaces.push(place);
        } else {
            mergedPlaces[duplicateIndex] = mergePlaces(
                mergedPlaces[duplicateIndex],
                place
            );
        }
    }

    return mergedPlaces;
}

module.exports = {
    mergeAndDeduplicatePlaces
};
