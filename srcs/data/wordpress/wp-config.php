<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * Localized language
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** Database username */
define( 'DB_USER', 'wp_user' );

/** Database password */
define( 'DB_PASSWORD', 'wp_password' );

/** Database hostname */
define( 'DB_HOST', 'mariadb' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',          '$$4V8;o8lSeUX${f<m43o$<@p$SEXbzH=BNs5%6DviC} Id{qh@_g_Adf1)}M#NW' );
define( 'SECURE_AUTH_KEY',   'oZI<{7NW]$Y<q,j;4iHw]b-%C|%D}zV#YHjoCKv:~?:|g-`hb8xs;{1UQwk*y;o?' );
define( 'LOGGED_IN_KEY',     'o&rcthK3%9+9BTflatiqx}YBV@TRcPXk>QIlb)ja,_P.jTCa;l5l2qF<Fb,9@LFF' );
define( 'NONCE_KEY',         'OM.`k+ugM0d!!&,gwB>p*8i!nm8qTR[?rmviw#S7PFo2YD-OHTq6xCLn`$p=gH:5' );
define( 'AUTH_SALT',         ',SIOLa*pA%VfZABe%>X4(|{z9kRJ8X1#Kwv?-h$gHt06L5ipN#U#:=Q*q3LAdyu?' );
define( 'SECURE_AUTH_SALT',  ')SAE&q{57H.s2A`F,6:Ymy7i31&RY;}iG;0OCmpg^/?j<iA={+~}[&&_ELV;OuEn' );
define( 'LOGGED_IN_SALT',    '^N_g.#5)o~${mP9(tMmN}Q+27D%d1`X}e[au1$|9CpwGjeJ.y>E,@nUY,^`gtNN`' );
define( 'NONCE_SALT',        'w~w)g=Zl0ZtX9|KN@PZy{h9#*ufFUO3jK/B>l27?7BgEC`r%Hg=L&{Ly7`Nmj+4!' );
define( 'WP_CACHE_KEY_SALT', 'quv0B3eo0Q&~FyWr-;~PA.i&N;1StqE~>nHf[j/I ){QlHJD9_tsnZVy)J{X{5|3' );


/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';


/* Add any custom values between this line and the "stop editing" line. */



/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
if ( ! defined( 'WP_DEBUG' ) ) {
	define( 'WP_DEBUG', false );
}

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
