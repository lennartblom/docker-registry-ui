<!--
Copyright (C) 2016-2018 Jones Magloire @Joxit

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
-->
<tag-history>
    <material-card ref="tag-history-tag" class="tag-history">
        <div class="material-card-title-action">
            <a href="#!taglist/{registryUI.taghistory.image}" onclick="registryUI.home();">
                <i class="material-icons">arrow_back</i>
            </a>
            <h2>History of Image Tag | { registryUI.taghistory.image }:{ registryUI.taghistory.tag } <i class="material-icons">history</i> </h2>
        </div>
        <div hide="{ registryUI.taghistory.loadend }" class="spinner-wrapper">
            <material-spinner></material-spinner>
        </div>

        <div show="{ registryUI.taghistory.loadend }">

            <material-card each="{ guiElement in registryUI.taghistory.elements }" class="tag-history-element">
                <div each="{ entry in guiElement }" class="{ entry.key }">
                    <div class="headline"><i class="material-icons"></i> <p>{ entry.key }</p></div>
                    <div class="value"> { entry.value } </div>
                </div>

            </material-card>
        </div>

    </material-card>

    <script type="text/javascript">
        console.log("taghistory script area");



        registryUI.taghistory.instance = this;
        registryUI.taghistory.display = function () {
            var oReq = new Http();
            registryUI.taghistory.instance.update();
            oReq.addEventListener('load', function () {
                console.log("taghistory addEventListener::load");
                registryUI.taghistory.elements = [];

                function modifySpecificAttributeTypes(value) {
                    if (attribute == "created") {
                        let date = new Date(value);
                        let year = date.getFullYear();
                        let month = date.getMonth();
                        let day = date.getDay();
                        let minutes = date.getMinutes();
                        let hours = date.getUTCHours();
                        let seconds = date.getSeconds();
                        let milliSeconds = date.getMilliseconds();

                        if (month < 10) {
                            month = '0' + month;
                        }

                        if (minutes < 10) {
                            minutes = '0' + minutes;
                        }
                        if (hours < 10) {
                            hours = '0' + hours;
                        }

                        value = day + "." + month + "." + year+ " | " + hours + ":" + minutes + ":" + seconds + "." + milliSeconds;
                    } else if (attribute == "container_config" || attribute == "config") {
                        value = "";
                    }
                    return value;
                }

                if (this.status == 200) {
                    var elements = JSON.parse(this.responseText).history || [];
                    for(var index in elements){
                        var parsedNestedElements = JSON.parse(elements[index].v1Compatibility || {});

                        var guiElements = [];
                        var guiElement = {};

                        for(var attribute in parsedNestedElements){
                            if(parsedNestedElements.hasOwnProperty(attribute)){
                                var value = parsedNestedElements[attribute];

                                value = modifySpecificAttributeTypes(value);
                                guiElement = {
                                    "key": attribute,
                                    "value": value
                                };
                                guiElements.push(guiElement);
                            }

                        }

                        registryUI.taghistory.elements.push(guiElements);
                    }
                } else if (this.status == 404) {
                    registryUI.snackbar('Manifest could not be fetched', true);
                } else {
                    registryUI.snackbar(this.responseText);
                }
            });
            oReq.addEventListener('error', function () {
                registryUI.snackbar(this.getErrorMessage(), true);
                registryUI.taghistory.elements = [];
            });
            oReq.addEventListener('loadend', function () {
                registryUI.taghistory.loadend = true;
                registryUI.taghistory.instance.update();
            });
            console.log("Trying to create GET call with image='" + registryUI.taghistory.image + "' and tag='" + registryUI.taghistory.tag + "'")
            oReq.open('GET', registryUI.url() + '/v2/' + registryUI.taghistory.image + '/manifests/' + registryUI.taghistory.tag);
            oReq.send();
        };


        registryUI.taghistory.display();
        registryUI.taghistory.instance.update();
    </script>
</tag-history>