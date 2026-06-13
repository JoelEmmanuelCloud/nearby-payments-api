DELETE FROM wallet_bindings
WHERE user_id IN (
    SELECT user_id FROM zklogin_salts
    WHERE salt ~ '[^0-9]' OR length(salt) > 39
);

DELETE FROM zklogin_salts
WHERE salt ~ '[^0-9]' OR length(salt) > 39;
