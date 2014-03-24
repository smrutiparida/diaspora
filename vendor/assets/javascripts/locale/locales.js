/*
 * This file specifies the language dependencies.
 *
 * Translations take up a lot of space and you are therefore advised to remove
 * from here any languages that you don't need.
 */

(function (root, factory) {
    require.config({
        paths: {
            "en": "locale/en/LC_MESSAGES/en"
        }
    });

    define("locales", [
        'en'
        ], function (en) {
            root.locales = {
                'en': en
            };
        });
})(this);