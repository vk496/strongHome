#!/bin/sh

set -e

CA_FILE=$1
HIDDEN_NETWORK=false

if [ ! "$CA_FILE" ]; then
	echo "Missing CA input"
	exit 1
fi

if [ ! "$2" ]; then
	echo "Missing Network name input"
	exit 1
else
	NETWORK_NAME="$2"
fi

if [ "$3" ]; then
	HIDDEN_NETWORK=true
fi


CA_UUID=$(uuidgen)
WIFI_UUID=$(uuidgen)

cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>PayloadContent</key>
	<array>
		<dict>
			<key>PayloadCertificateFileName</key>
				<string>AAA ROOT CA strongHome.cer</string>
			<key>PayloadContent</key>
				<data>
					$(openssl x509 -in $1 -out - -outform der | base64)
				</data>
			<key>PayloadDescription</key>
				<string>StrongHome CA certificate</string>
			<key>PayloadDisplayName</key>
				<string>AAA ROOT CA strongHome</string>
			<key>PayloadIdentifier</key>
				<string>com.apple.security.root.${CA_UUID}</string>
			<key>PayloadType</key>
				<string>com.apple.security.root</string>
			<key>PayloadUUID</key>
				<string>${CA_UUID}</string>
			<key>PayloadVersion</key>
				<integer>1</integer>
		</dict>
		<dict>
			<key>EAPClientConfiguration</key>
			<dict>
				<key>AcceptEAPTypes</key>
				<array>
					<integer>25</integer>
					<integer>21</integer>
				</array>
				<key>OneTimeUserPassword</key>
					<false/>
				<key>OuterIdentity</key>
					<string>anonymous</string>
				<key>PayloadCertificateAnchorUUID</key>
				<array>
					<string>${CA_UUID}</string>
				</array>
				<key>TLSTrustedServerNames</key>
					<array/>
				<key>TTLSInnerAuthentication</key>
					<string>PAP</string>
			</dict>
			<key>EncryptionType</key>
				<string>WPA</string>
			<key>HIDDEN_NETWORK</key>
				<${HIDDEN_NETWORK}/>
			<key>IsHotspot</key>
				<false/>
			<key>PayloadDescription</key>
				<string>Configure strongHome WiFi</string>
			<key>PayloadDisplayName</key>
				<string>SSID ${NETWORK_NAME}</string>
			<key>PayloadIdentifier</key>
				<string>com.apple.wifi.managed.${WIFI_UUID}</string>
			<key>PayloadType</key>
				<string>com.apple.wifi.managed</string>
			<key>PayloadUUID</key>
				<string>${WIFI_UUID}</string>
			<key>PayloadVersion</key>
				<integer>1</integer>
			<key>ProxyType</key>
				<string>None</string>
			<key>SSID_STR</key>
				<string>${NETWORK_NAME}</string>
		</dict>
	</array>
	<key>PayloadDescription</key>
		 <string>Configuration profile of strongHome 802.1X networks</string>
	<key>PayloadDisplayName</key>
		<string>StrongHome Profile</string>
	<key>PayloadIdentifier</key>
		<string>stronghome.profile</string>
	<key>PayloadRemovalDisallowed</key>
		<false/>
	<key>PayloadType</key>
		<string>Configuration</string>
	<key>PayloadUUID</key>
		<string>$(uuidgen)</string>
	<key>PayloadVersion</key>
		<integer>1</integer>
</dict>
</plist>
EOF
