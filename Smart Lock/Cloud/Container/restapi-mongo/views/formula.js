// function calcTDS(val){
//     if (val === 600)
//         return 3.5;
//     else if (val == 300)
//         return 1;
//     else if (val > 300 && val < 600){
//         val -= 300;
//         let varVar = 1 + (val * 0.00833)
//         return varVar;
//     }
//     else if (val > 600 && val <900){
//         val -= 600;
//         varVar = 3.5 - (val * 0.005833);
//         return varVar;
//     }
//     else if (val >= 900){
//         val -= 900;
//         varVar = 1 - (val * 0.005833 * 2);
//         if(varVar < 0)
//             return 0;
//         return varVar;
//     }
//     else{
//         val = 300 - val;
//         varVar = 1 - (val * 0.005833 * 2);
//         if(varVar < 0)
//             return 0;
//         return varVar;
//     }
// }

// function calcPh(val){
//     if (val == 7.5)
//         return 3.5;
//     else if (val == 6.5)
//         return 2;
//     else if (val > 6.5 && val < 7.5){
//         val -= 6.5;
//         let varVar = 2 + (val * 0.15);
//         return varVar;
//     }
//     else if (val > 7.5 && val <8.5){
//         val -= 7.5;
//         let varVar = 3.5 - (val * 0.15);
//         return varVar;
//     }
//     else if (val >= 8.5){
//         val -= 8.5;
//         let varVar = 2 - (val * 0.15 * 2);
//         if(varVar < 0)
//             return 0;
//         return varVar;
//     }
//     else{
//         val = 6.5 - val;
//         let varVar = 2 - (val * 0.15 * 2);
//         if(varVar < 0)
//             return 0;
//         return varVar;
//     }
// }

// function calcTur(val){
//     if(val > 16 && val < 40)
//         return 2;
//     else
//         return 1;
// }

// function calcTemp(val){
//     if(val < 1)
//         return 1;
//     else if(val < 3)
//         return 0.7;
//     else
//         return 0.1;
// }

// const calScale = (tds, pH, tur, temp) => {
//     return calcTDS(tds) + calcPh(pH) + calcTur(tur) + calcTemp(temp);
// }

// module.exports = calScale;