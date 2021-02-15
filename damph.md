The following program is comprised of three files and is aimed to be used as a Debian-Apache-MySQL-PHP-HTTPS version-agnostic environment bootstrapper.

It is aimed to be used on raw Debian systems (anything that doesn't come with the OS wasn't installed) and to establish web domain associated web applications.

## The program

### File 1

This file contains fundamental installation and/or configuration commands and comprised of two parts:

* The first part is a `cat` heredocument for `.profile` aimed to declare some global modes, variables and functions ("global" as to effect all shell sessions) that from my experience are harmless although global.

* The second part is a "sourcing" of `.profile` to ensure the variables will take effect in the very first shell session in which they are declared at and also after every booting of Debian.

File 1 code is as follows (clarifications available below the code block).

    #!/bin/bash
    
    cat <<-EOF >> "$HOME"/.profile
    	set -x
    	complete -r
    
    	export war="/var/www/html"
    	export dmp="phpminiadmin"
    
    	export -f war ssr tmd # Create execution shortcuts to the following functions:
    
    	war() {
    		cd $war/
    	}
    	
    	ssr() {
    		chown -R www-data:www-data "$war"/
    		chmod -R a-x,a=rX,u+w "$war"/
    		systemctl restart apache*
    		chmod -R 000 "$war"/"$dmp"/
    	}
    	tmd() {
    		chmod -R a-x,a=rX,u+w "$war"/"$dmp"/
    		echo "chmod -R 000 "$war"/"$dmp"/" | at now + 1 hours
    	}
    EOF
    
    source "$HOME"/.profile 2>/dev/null

### File 1 modes

* The mode `set -x` means constant working in full debug mode
* The mode `complete -r` means constant removal of messy output of programmable completion (by calling to functions, etc) common in full debug mode

### File 1 variables

* The `war` variable's value reflects a user's preferred *Web Application Root* directory
* The `dmp` variable's value reflects a user's preferred *Database Management Program* (such as *phpMiniAdmin*)

### File 1 functions

* The function `war` means something like "navigate to Web Application Root easy and fast"<br>
* The function `ssr` means **Secured Server Restart:**; that is, restart web server with repeating basic security directives that might have been mistakenly changed, as well as allowing temporary management of MySQL database by a database management program<br>
* The function `tmd` means *Temporarily Manage Database* and is useful after DB-manager security lock by `ssr()`

### File 2

This file contains basic application installation and/or configuration commands.

    #!/bin/bash
    
    apt update -y
    apt upgrades ufw sshguard unattended-upgrades wget curl git zip unzip tree -y
    ufw --force enable
    ufw allow 22,25,80,443
    
    apt install lamp-server^ python-certbot-apache
    curl -sS https://getcomposer.org/installer -o composer-setup.php
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    a2enmod http2 deflate expires

### File 3

This file uses to create an Apache virtual host and associated files.

This file should be executed only after creating a CMS-contexed database on top of MySQL program, based on a single pattern of data, **the web domain** which also uses as the name for:

* Web application DB user
* Web application DB instance
* Web application directory (explained in following chapter)

The file:

    #!/bin/bash
    
    read -p "Have you created db credentials already?" yn
    case $yn in
    	[Yy]* ) break;;
    	[Nn]* ) exit;;
    	* ) echo "Please create db credentials and then comeback;";;
    esac
    
    function read_and_verify  {
        read -p "$1:" tmp1
        read -p "$2:" tmp2
        if [ "$tmp1" != "$tmp2" ]; then
            echo "Values unmatched. Please try again."; return 2
        else
            read "$1" <<< "$tmp1"
        fi
    }
    
    read_and_verify domain "Please enter the domain of your web application twice" 
    read_and_verify dbrootp "Please enter the app DB root password twice" 
    read_and_verify dbuserp "Please enter the app DB user password twice"
    
    cat <<-EOF > /etc/apache2/sites-available/$domain_2.conf
    	<VirtualHost *:80>
    		ServerAdmin admin@"$domain_2"
    		ServerName ${domain_2}
    		ServerAlias www.${domain_2}
    		DocumentRoot $war/${domain_2}
    		ErrorLog ${APACHE_LOG_DIR}/error.log
    		CustomLog ${APACHE_LOG_DIR}/access.log combined
    	</VirtualHost>
    EOF
    
    ln -sf /etc/apache2/sites-available/"$domain_2".conf /etc/apache2/sites-enabled/
    certbot --apache -d "$domain_2" -d www."$domain_2"

## Possible appendix - install Drupal

Because installing a composer-driven drupal project with a local Drush was the original aim of this program, I append the following:

    composer create-project drupal-composer/drupal-project "$war"/"$domain"
    cp "$drt/$domain"/wp-config-sample.php "$war/$domain"/wp-config.php
    drush --root="$war" --uri="$domain" pm install redirect token metatag draggableviews
    drush --root="$war" --uri="$domain" en language content_translation redirect token metatag draggableviews

## Notes

* The program doesn't cover backups because I personally believe that every hosting provider and that includes dedicating hosting, whether semi (commercial) or full (private), should include a reliable, most preferably communally maintained automatic daily backup mechanism, alongside a manual backup standardized routine procedure (say doing manual backup each quarter or half a year).
* The program doesn't cover web application upgrades because I personally believe that every CMS should include an upgrade mechanism of its own by default, without bestowing upon users the need do maximal upgrade automation from backend.

## My question

**How would you revise this Debian-Apache-MySQL-PHP-HTTPS version-agnostic environment bootstrapper?**
