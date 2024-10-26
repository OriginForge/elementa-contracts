// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import {modifiersFacet} from "../shared/utils/modifiersFacet.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {ElementaItem, EquipmentType, ElementaNFT} from "../shared/storage/structs/AppStorage.sol";
import {IERC721} from "../shared/interfaces/IERC721.sol";
import {svg} from "../shared/libraries/svg.sol";
import {Metadata, DisplayType} from "../shared/libraries/Metadata.sol";
import {json} from "../shared/libraries/json.sol";
import {Solarray} from "../shared/libraries/Solarray.sol";

import {LibString} from "solady/src/utils/LibString.sol";

contract nftFacet is modifiersFacet {
    using svg for *;
    using Metadata for *;

    function nft_getUri(uint _tokenId) external view returns (string memory) {
        string memory metaData = Metadata.base64JsonDataURI(
            json.objectOf(
                Solarray.strings(
                    json.property(
                        "name",
                        string.concat(
                            "Elementa #",
                            LibString.toString(_tokenId)
                        )
                    ),
                    json.property(
                        "description",
                        "Test Elementa dNFT, for testing"
                    ),
                    json.property(
                        "image",
                        Metadata.base64SvgDataURI(_generateSVG(_tokenId))
                    )
                )
            )
        );

        return metaData;
    }

    function nft_onlyCharacterImage(uint _tokenId) external view returns (string memory) {
        return _generateOnlyCharacterSVG(_tokenId);
    }

    function getImage(
        string memory id,
        string memory base64Data
    ) internal pure returns (string memory) {
        return
            string.concat(
                svg.el(
                    "image",
                    string.concat(
                        svg.prop("id", id),
                        svg.prop("width", "50%"),
                        svg.prop("height", "50%"),
                        svg.prop("transform", "translate(-.04 .08)"),
                        svg.prop("href", base64Data) // 'href' 속성으로 변경
                    ),
                    ""
                )
            );
    }

    function getTierOutline(uint _grade) internal view returns (string memory) {
        return
            svg.linearGradient(
                string.concat(
                    svg.prop("id", "gradeOutline"),
                    svg.prop("x1", "0%"),
                    svg.prop("y1", "0%"),
                    svg.prop("x2", "100%"),
                    svg.prop("y2", "100%")
                ),
                string.concat(
                    svg.el(
                        "stop",
                        string.concat(
                            svg.prop("offset", "0%"),
                            svg.prop(
                                "style",
                                // s.gradeOutlines[nft.grade].stopColor
                                "stop-color:#afafaf;stop-opacity:1"
                            )
                        ),
                        svg.el(
                            "animate",
                            string.concat(
                                svg.prop("attributeName", "stop-color"),
                                svg.prop(
                                    "values",
                                    // s.gradeOutlines[nft.grade].animateColors
                                    "#afafaf;#d2d4dc;#afafaf"
                                ),
                                svg.prop("dur", "2s"),
                                // svg.prop(
                                //     "dur",
                                //     s.gradeOutlines[nft.grade].animateDuration
                                // ),
                                svg.prop("repeatCount", "indefinite")
                            )
                        )
                    ),
                    svg.el(
                        "stop",
                        string.concat(
                            svg.prop("offset", "100%"),
                            svg.prop(
                                "style",
                                "stop-color:#afafaf;stop-opacity:1"
                            )
                        ),
                        svg.el(
                            "animate",
                            string.concat(
                                svg.prop("attributeName", "stop-color"),
                                svg.prop("values", "#afafaf;#d2d4dc;#afafaf"),
                                svg.prop("dur", "2s"),
                                svg.prop("repeatCount", "indefinite")
                            )
                        )
                    )
                )
            );
    }

    function getBackground(
        uint _tokenId
    ) internal view returns (string memory) {
        return
            svg.linearGradient(
                string.concat(
                    svg.prop("id", "background"),
                    svg.prop("x1", "0%"),
                    svg.prop("x2", "0%"),
                    svg.prop("y1", "0%"),
                    svg.prop("y2", "100%")
                ),
                string.concat(
                    svg.el(
                        "stop",
                        string.concat(
                            svg.prop("offset", "0%"),
                            svg.prop("stop-color", "#fffff2")
                        ),
                        ""
                    ),
                    svg.el(
                        "stop",
                        string.concat(
                            svg.prop("offset", "100%"),
                            svg.prop("stop-color", "#f9f9f9")
                        ),
                        ""
                    )
                )
            );
    }

    function _generateSVG(uint _tokenId) public view returns (string memory) {
        ElementaNFT memory nft = s.elementaNFTs[_tokenId];

        return
            string.concat(
                svg.top(
                    svg.prop("viewBox", "0 0 250 250"),
                    string.concat(
                        // Defining gradients
                        svg.el(
                            "defs",
                            "",
                            string.concat(
                                getTierOutline(nft.grade),
                                getBackground(_tokenId)
                            )
                        ),
                        // Defining background and border
                        svg.rect(
                            string.concat(
                                svg.prop("width", "100%"),
                                svg.prop("height", "100%"),
                                svg.prop("fill", svg.getDefURL("background")),
                                svg.prop(
                                    "stroke",
                                    svg.getDefURL("gradeOutline")
                                ),
                                svg.prop("stroke-width", "7")
                            ),
                            ""
                        ),
                        // svg.el(
                        //     "g",
                        //     svg.prop("transform", "translate(62.5, 55.5)"), // (250 - 64) / 2 = 93, 이미지를 중앙으로 위치
                        //     string.concat(
                        //         // outline
                        //         getImage(
                        //             "_charOutline_xA0_image",
                        //             "data:image/svg;base64,iVBORw0KGgoAAAANSUhEUgAAAEEAAABBCAYAAACO98lFAAAACXBIWXMAAAsSAAALEgHS3X78AAACh0lEQVR4nO2bMW/TQBSAv5QgUTXJiLJ5YiFTl4xIwIDIws7KwL/I0N/AylrxC9igUsduDO2CGLohj21BQkI1Az3LNk6a+t57vqD3TVFsOXffvffOOZ8HJEY2nRfN786/nww0f1P14lWanWt2rHr86OwQgFcf3gJwcXCpKmJH68JVsum8mCzHTJbjsoNtI350dlgeb7uGVvuGWhdu4+rhb+BvZ58+fr3yvOef3wAwMmqeqYQqNyL+SYFSQF5vmmY6mNSEEMqT5biMhk/P3pfRsPNut3Z+VYB2PQCjmhA6cXFwySgfMsqH5YgHwvdNARaYzQ5QL26T5bh2bFWHtaMAjCVUCTNGwCLsV2GSDqnjEugpHW678bFOC3MJm975WYrobXY4Pf/Yes4sW5SfrUSY/4Fa1fkmljLUJWwy+uuYZQsG8PXn9a/9PP/yQ7RxN5jNDl0EBO7dHz56+eLJlWBzaqhGwl1TYB2zbMFo7wGn347F26wiQbLzVbTqhN8soRAJWlFQJUSEVDSISsim80Kz801m2UJEhMjKkub6nwWiNcEyCgLZdF7EDsJWF0Yp6dH5ZFEIbyO2UG51JEjhEohIhxTSoEnXtDCNhOsizZnUVMKgv8XttdhKSNNBt6FJsR4EutQFnx1wCYBLAFwC4BIAlwC4BMAlAC4BcAmASwAiJVSfCKVA1/Z0WnIPf05SXGrvss7o6YCAhFRSIqYdIpGQioiu/BfpEDsIUc8iUyiQEk+oxSKhj5SQ+k2Rpc/YzVldkNyjIL4/IXy22KQBCUoIaK5GS+9SAeXZQbpOaNUdky18EBcV2rtbTd+BCmwipDnqW/8iGMTdS2z93uY2NhHS16tAjuM4DvAHUwT634NLx7kAAAAASUVORK5CYII="
                        //         ),
                        //         // arm
                        //         getImage(
                        //             "_charAmr_xA0_image",
                        //             "data:image/svg;base64,iVBORw0KGgoAAAANSUhEUgAAAEEAAABBCAYAAACO98lFAAAACXBIWXMAAAsSAAALEgHS3X78AAAA5ElEQVR4nO3WsQ3CMBCF4UuWSCQKM4VbxmAYaLIALJAZaCmggYICUaWnQKIIJXWUHE2ygG1igv6vj+/07mxFBAAAAAAAAAAAAAAAAAAAAAAwbSa3anKrsfsIIY3dQCg+Q/EO4Re2wbcHrxDKXRmkiRAe9TVx/Xby1yHEALxDGLYhtsOlcg4j2CbEuBJDTd9BBAlhbmYhjolW2zmEJHV+h77GtSfnELRTbZtORETW20Ikkcb1LA/P1aboRETaphVVfY9a/Xiuliaztcmtmsze96fbYtQGeia3r/5HqYtRHwAA4O99AKTCO8eSAA8eAAAAAElFTkSuQmCC"
                        //         ),
                        //         // leg
                        //         getImage(
                        //             "_leg_xA0_image",
                        //             "data:image/svg;base64,iVBORw0KGgoAAAANSUhEUgAAAEEAAABBCAYAAACO98lFAAAACXBIWXMAAAsSAAALEgHS3X78AAAAfUlEQVR4nO3UsQ3CMBAF0B+moMsWjO0l0rEFXbaABksBhEik2ID0XmfrdKe74icAAAAAAAAAAAAAAAAAAPBPhl6DxuPpunxf5vPb2Vtq93Bo2fxZmUrKVJK8LlrV/2Vta12PUH1artfy1VeO8GscIR2DMXnMgbXB2DoUubsB+bMfnf2sWikAAAAASUVORK5CYII="
                        //         ),
                        //         // eyes
                        //         getImage(
                        //             "_eyes_xA0_image",
                        //             "data:image/svg;base64,iVBORw0KGgoAAAANSUhEUgAAAEEAAABBCAYAAACO98lFAAAACXBIWXMAAAsSAAALEgHS3X78AAAAeklEQVR4nO3UsQ3CMBBA0YAYwhGFEUOYKvtLbEHHCiksU5kGAUpkRyneq665f648DAAAAAAAAADQy6FnPIZU6vx43lffatXZXAypxJBKlfNc/m99ynl+N2qz9VuPrYPfXM/TpntLnHofuIy3XTR+8ScAAAAAAAAAQFcvmTMvYSxs+bMAAAAASUVORK5CYII="
                        //         ),
                        //         // mouth
                        //         getImage(
                        //             "_mouth_xA0_image",
                        //             "data:image/svg;base64,iVBORw0KGgoAAAANSUhEUgAAAEEAAABBCAYAAACO98lFAAAACXBIWXMAAAsSAAALEgHS3X78AAAASElEQVR4nO3PoQ3AIAAEQLoFji26v2YLHFuARWBICk3InXzz/yEAAAAAAAAAAAC3S/FtK/lOz+nC0exwqfnXTQAAAAAAAABf6ftjBtraAp8tAAAAAElFTkSuQmCC"
                        //         )
                        //     )
                        // ),
                        svg.el(
                            "g",
                            svg.prop("transform", "translate(62.5, 55.5)"),
                            _generateOnlyCharacterSVG(_tokenId)
                        ),
                        svg.text(
                            string.concat(
                                svg.prop("x", "5%"),
                                svg.prop("y", "85%"),
                                svg.prop("font-family", "Arial"),
                                svg.prop("font-size", "15"),
                                svg.prop("fill", "#000"),
                                svg.prop("text-anchor", "start")
                            ),
                            string.concat(
                                "ElementaNFT #",
                                LibString.toString(_tokenId)
                            )
                        ),
                        svg.text(
                            string.concat(
                                svg.prop("x", "5%"),
                                svg.prop("y", "90%"),
                                svg.prop("font-family", "Arial"),
                                svg.prop("font-size", "10"),
                                svg.prop("fill", "#000"),
                                svg.prop("text-anchor", "start")
                            ),
                            string.concat(
                                "Level: ",
                                LibString.toString(
                                    s.elementaNFTs[_tokenId].level
                                )
                            )
                        ),
                        svg.text(
                            string.concat(
                                svg.prop("x", "5%"),
                                svg.prop("y", "95%"),
                                svg.prop("font-family", "Arial"),
                                svg.prop("font-size", "10"),
                                svg.prop("fill", "#000"),
                                svg.prop("text-anchor", "start")
                            ),
                            string.concat(
                                "&#128150; x ",
                                LibString.toString(
                                    s.elementaNFTs[_tokenId].heartPoint
                                )
                            )
                        ),
                        svg.text(
                            string.concat(
                                svg.prop("x", "95%"),
                                svg.prop("y", "95%"),
                                svg.prop("font-family", "Arial"),
                                svg.prop("font-size", "10"),
                                svg.prop("fill", "#000"),
                                svg.prop("text-anchor", "end")
                            ),
                            string.concat(
                                "exp: ",
                                LibString.toString(
                                    s.elementaNFTs[_tokenId].exp
                                )
                            )
                        )
                    )
                )
            );
    }

    function nft_generateOnlyCharacterSVG(uint _tokenId) external view returns (string memory) {
        return Metadata.base64SvgDataURI(_generateOnlyCharacterSVG(_tokenId));
    }
    function _generateOnlyCharacterSVG(uint _tokenId) internal view returns (string memory) {
        ElementaNFT memory nft = s.elementaNFTs[_tokenId];
        uint nftRandomValue = nft.originRandomValue;
        
        // nftRandomValue를 사용하여 랜덤 속성 생성
        uint hue = nftRandomValue % 360;
        uint saturation = 60 + (nftRandomValue % 30);
        uint lightness = 74 + (nftRandomValue % 20);
        uint circleOpacity1 = 30 + (nftRandomValue % 50);
        uint circleOpacity2 = 50 + (nftRandomValue % 40);
        
        
        // 패턴의 width와 height를 랜덤으로 설정
        uint patternWidth = 15 + (nftRandomValue % 20);  // 15에서 34 사이의 값
        uint patternHeight = 15 + ((nftRandomValue / 100) % 20);  // 15에서 34 사이의 값

        return
            string.concat(
                svg.top(
                    string.concat(
    svg.prop("viewBox", "-30 -55 120 120"), // 여백을 주어 중앙 정렬 보정
    svg.prop("width", "100%"),
    svg.prop("height", "100%"),
    svg.prop("preserveAspectRatio", "xMidYMid meet") // 중앙 정렬 강제
),
                    string.concat(
                        "<defs>",
                        "<pattern ",
                        "id='my-pattern' ",
                        string.concat("width='0.", LibString.toString(patternWidth), "' "),
                        string.concat("height='0.", LibString.toString(patternHeight), "' "), // transparent space
                        "viewBox='0 0 40 40' ",
                        string.concat("patternTransform='translate(0 ", LibString.toString(nftRandomValue % 200), ") rotate(", LibString.toString(nftRandomValue % 360), ")' "),
                        ">",
                        string.concat("<rect width='100%' height='100%' fill='hsl(", LibString.toString(hue), ", ", LibString.toString(saturation), "%, ", LibString.toString(lightness), "%)' />"),
                        string.concat("<circle cx='20' cy='20' r='15' fill='hsl(", LibString.toString(hue), ", ", LibString.toString(saturation), "%, ", LibString.toString(lightness - 50), "%)' fill-opacity='.", LibString.toString(circleOpacity1), "'/>"),
                        string.concat("<circle cx='20' cy='20' r='9' fill='hsl(", LibString.toString(hue), ", ", LibString.toString(saturation), "%, ", LibString.toString(lightness - 50), "%)' fill-opacity='.", LibString.toString(circleOpacity2), "' />"),
                        string.concat("<circle cx='20' cy='20' r='3' fill='hsl(", LibString.toString(hue), ", ", LibString.toString(saturation), "%, ", LibString.toString(lightness - 60), "%)' />"),
                        "</pattern>",
                        "</defs>",
                        "<g id='egg' transform='translate(0 0)'>",
                        "<path d='m53.6 29.8c-2.5-18-13.9-27.8-21.6-27.8s-19.1 9.8-21.6 27.8c-2.4 18 5.5 32.2 21.6 32.2s24-14.2 21.6-32.2z' fill='url(#my-pattern)'/>",
                        string.concat("<path d='m53.6 29.8c-2-14.2-9.5-23.3-16.4-26.5 4.7 4.7 8.9 12.1 10.2 22.1 2.5 18-5.4 32.2-21.6 32.2-3.5 0-6.6-.7-9.2-1.9 3.7 4 8.9 6.3 15.4 6.3 16.1 0 24-14.2 21.6-32.2'  opacity='0.", '4', "'/>"),
                        "</g>"
                    )
                )
            );
    }

    function _getEquipmentSVG(
        uint _tokenId
    ) internal view returns (ElementaNFT memory) {
        return s.elementaNFTs[_tokenId];
    }

    function _updateUri(uint _tokenId) public {
        IERC721 nft = IERC721(s.contracts["nft"]);
        nft._update_metadata_uri(_tokenId);
    }
}
