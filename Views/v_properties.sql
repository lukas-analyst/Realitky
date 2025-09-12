CREATE OR REPLACE VIEW realitky.stats.v_properties AS SELECT
  property_price.price_amount,
  property.source_url,
  property_type.type_name AS property_type_description,
  property_subtype.subtype_name AS property_subtype_description,
  property.property_name,
  CONCAT(
    property.address_street, ' ', property.address_house_number, ', ', property.address_city
  ) AS property_address,
  property_image.img_link,
  property.address_city,
  property.src_web
FROM
  realitky.cleaned.property AS property
    JOIN realitky.cleaned.property_type AS property_type
      ON property.property_type_id = property_type.property_type_id
      AND property_type.del_flag = false
    JOIN realitky.cleaned.property_subtype AS property_subtype
      ON property.property_subtype_id = property_subtype.property_subtype_id
      AND property_subtype.del_flag = false
    JOIN realitky.cleaned.property_price AS property_price
      ON property.property_id = property_price.property_id
      AND property.src_web = property_price.src_web
      AND property_price.del_flag = false
      AND property_price.price_amount > 0
    JOIN realitky.cleaned.property_image AS property_image
      ON property.property_id = property_image.property_id
      AND property.src_web = property_image.src_web
      AND property_image.del_flag = false
WHERE
  property.is_active_listing = true
  AND property.del_flag = false
ORDER BY
  property.ins_dt DESC,
  property.upd_dt DESC;