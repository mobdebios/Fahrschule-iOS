UPDATE ZQUESTION SET ZDELETED = 1 WHERE Z_PK IN (795, 752, 767, 768, 1413);
DELETE FROM ZQUESTIONTAGS WHERE ZWHATQUESTION IN (795, 752, 767, 768, 1413);
DELETE FROM ZLEARNINGSTATISTIC WHERE ZWHATQUESTION IN (795, 752, 767, 768, 1413);
UPDATE ZQUESTION SET ZLICENSECLASSFLAG = ZLICENSECLASSFLAG | 1 WHERE Z_PK IN (1435,1436,1439);
UPDATE ZQUESTION SET ZLICENSECLASSFLAG = ZLICENSECLASSFLAG | 2 WHERE Z_PK IN (572,590,763,907,908,947,1288,1289,1290,1291,1292,1293,1415,1435,1436,1439);
UPDATE ZQUESTION SET ZLICENSECLASSFLAG = ZLICENSECLASSFLAG | 8192 WHERE Z_PK IN (537,538,539,540,543,544,545,546,547,548,549,563,564,565,566,567,568,572,573,576,577,578,579,580,590,591,592,593,594,595,596,597,598,599,600,601,602,603,604,605,606,607,608,609,610,611,612,613,614,615,624,625,626,627,628,629,630,634,635,636,637,640,641,642,643,644,647,648,649,650,651,652,653,654,655,656,723,724,744,745,746,747,748,763,764,765,841,842,843,844,845,877,878,879,880,881,882,883,884,885,886,887,888,889,890,891,892,893,894,895,896,897,898,899,900,901,903,907,908,909,910,911,912,913,914,943,944,945,946,947,948,949,950,951,968,978,979,980,981,990,991,992,993,994,1030,1031,1032,1033,1034,1035,1036,1045,1046,1051,1053,1054,1055,1065,1066,1078,1079,1080,1081,1083,1089,1090,1091,1092,1093,1094,1095,1096,1097,1098,1107,1109,1110,1111,1112,1113,1114,1115,1116,1117,1118,1119,1120,1121,1122,1142,1143,1144,1145,1146,1247,1248,1249,1250,1251,1252,1253,1254,1255,1256,1257,1258,1259,1260,1261,1262,1263,1264,1265,1266,1267,1268,1269,1270,1271,1272,1273,1274,1275,1276,1277,1278,1279,1283,1284,1285,1286,1287,1288,1289,1290,1291,1292,1293,1401,1402,1403,1404,1405,1406,1407,1408,1409,1410,1411,1412,1414,1415,1416,1417,1418,1419,1420,1421,1422,1423,1424,1425,1426,1427,1428,1435,1436,1439,1495,1496,1497,1498,1499,1500,1501,1504,1505,1506,1508,1509,1522,1523,1524,1525,1526,1527,1528);
UPDATE ZQUESTION SET ZLICENSECLASSFLAG = ZLICENSECLASSFLAG | 16384 WHERE Z_PK IN (546,547,559,561,562,567,568,569,572,573,578,579,580,587,592,593,594,595,596,597,598,599,600,601,602,603,607,611,613,615,630,634,635,636,641,642,643,644,647,648,650,651,652,653,654,655,664,746,747,748,751,753,759,760,761,762,763,764,843,844,845,892,893,894,895,896,897,898,899,900,903,904,907,908,946,951,968,979,980,981,1030,1045,1046,1054,1055,1078,1079,1080,1081,1107,1118,1119,1120,1143,1144,1145,1146,1263,1264,1265,1266,1267,1268,1269,1270,1271,1272,1273,1274,1275,1276,1277,1278,1279,1284,1285,1287,1415,1416,1417,1419,1420,1421,1422,1423,1424,1425,1426,1427,1428,1435,1436,1439,1449,1501,1506,1508,1509,1528);
UPDATE ZQUESTION SET ZLICENSECLASSFLAG = ZLICENSECLASSFLAG | 24576 WHERE ZLICENSECLASSFLAG = 8191;