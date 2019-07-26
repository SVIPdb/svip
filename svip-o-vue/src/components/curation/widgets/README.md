# NotificationCard

This Notification card allows to display a card which contains a table filled with samples waiting to be curated or reviewed

## Props

<!-- @vuese:NotificationCard:props:start -->
|Name|Description|Type|Required|Default|
|---|---|---|---|---|
|items|The items of the table|`Array`|`true`|The default value is an empty array: `[]`|
|fields|The fields of the table|`Array`|`true`|The default value is an empty array: `[]`|
|title|The title of the card|`String`|`true`|The default value is: `DEFAULT_TITLE`|
|sortBy|The default column used to sort (Desc) the table|`String`|`false`|The default valie is: `id`|

<!-- @vuese:NotificationCard:props:end -->


## Methods

<!-- @vuese:NotificationCard:methods:start -->
|Method|Description|Parameters|
|---|---|---|
|setFlagClass|Used to set up the correct flag class depending on the days left|`Number` Days left|
|setBadgeClass|Used to set up the correct badge depending on the status|`String` Curation status|

<!-- @vuese:NotificationCard:methods:end -->


