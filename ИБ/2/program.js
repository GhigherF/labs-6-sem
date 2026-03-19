import  exceljs from "exceljs"
import fs from "fs/promises"
const workbook = new exceljs.Workbook();

const SURNAME_CHUV = "Дмитроченко";
const NAME_CHUV = "Кирилл";
const PATRONYMIC_CHUV = "Денисович";

const SURNAME_ALB = "Dmitrochenko";
const NAME_ALB = "Kirill";
const PATRONYMIC_ALB = "Denisovich";



const sheet1 = workbook.addWorksheet('Чувашский');
const sheet2 = workbook.addWorksheet('Албанский');
const sheet3 = workbook.addWorksheet('Бинарные');

let chuvash_entropy = 0;
let alban_entropy = 0;
let chuv_binary_entropy = 0;
let alban_binary_entropy = 0;


function stringToUTF8Binary(str) {
  return [...new TextEncoder().encode(str)]
    .map(byte => byte.toString(2).padStart(8, '0'))
    .join(' ');
}
async function chuvashia(){
let chuvash = await fs.readFile("Чувашский.txt");
sheet1.addRow(["Буква", "Частота", "Вероятность","%", "Энтропия"])
let chuvash_map = {};
chuvash = chuvash.toString().toUpperCase();
for (let symbol of chuvash) {chuvash_map[symbol] = (chuvash_map[symbol] || 0) + 1;}

let letters = Object.keys(chuvash_map).filter(x => /^\p{L}$/u.test(x));

let SUM = 0;
letters.forEach(letter => SUM += chuvash_map[letter]);

let sorted = Object.entries(chuvash_map)
    .filter(([letter]) => /^\p{L}$/u.test(letter))
    .sort((a,b)=>b[1]-a[1]);

sorted.forEach(([letter,count])=>{
    sheet1.addRow([
        letter,
        count,
        count / SUM * 100,
        '%',
        - Math.log2(count/SUM)* (count/SUM)
    ])
});

sheet1.getCell("H10").value="H="
sheet1.getCell("I10").value={
    formula:`SUM(E2:E${letters.length+1})`
}
chuvash_entropy = sorted.reduce((sum,[,count])=>sum + (-Math.log2(count/SUM)*(count/SUM)),0);

if(SURNAME_CHUV && NAME_CHUV && PATRONYMIC_CHUV){
    const fio = (SURNAME_CHUV + NAME_CHUV + PATRONYMIC_CHUV).toUpperCase();
    const fio_binary = stringToUTF8Binary(fio);
    const bit_count = fio_binary.replace(/\s/g,'').length;
    const info = fio.length * chuvash_entropy;
    
    sheet1.getCell("H12").value="ФИО:";
    sheet1.getCell("I12").value=fio;
    sheet1.getCell("H13").value="Длина:";
    sheet1.getCell("I13").value=fio.length;
    sheet1.getCell("H14").value="Информация (биты):";
    sheet1.getCell("I14").value=info;
    sheet1.getCell("H15").value="Двоичное:";
    sheet1.getCell("I15").value=fio_binary;
    sheet1.getCell("H16").value="Битов:";
    sheet1.getCell("I16").value=bit_count;
    
    sheet1.addRow([]);
    sheet1.addRow(["Вероятность ошибки","H канала","Информация (биты)"]);
    
    [0.1, 0.5, 1.0].forEach(p => {
        const H_channel = p === 0 || p === 1 ? 0 : -p*Math.log2(p) - (1-p)*Math.log2(1-p);
        const info_with_error = fio.length * (chuvash_entropy - H_channel);
        sheet1.addRow([p, H_channel, info_with_error]);
    });
}
}
async function albania(){
let alban = await fs.readFile("Албанский.txt");
sheet2.addRow(["Буква", "Частота", "Вероятность","%", "Энтропия"])
let alban_map = {};
alban = alban.toString().toUpperCase();
for (let symbol of alban) {alban_map[symbol] = (alban_map[symbol] || 0) + 1;}

let letters = Object.keys(alban_map).filter(x => /^\p{L}$/u.test(x));

let SUM = 0;
letters.forEach(letter => SUM += alban_map[letter]);

let sorted = Object.entries(alban_map)
    .filter(([letter]) => /^\p{L}$/u.test(letter))
    .sort((a,b)=>b[1]-a[1]);

sorted.forEach(([letter,count])=>{
    sheet2.addRow([
        letter,
        count,
        count / SUM * 100,
        '%',
        - Math.log2(count/SUM)* (count/SUM)
    ])
});

sheet2.getCell("H10").value="H="
sheet2.getCell("I10").value={
    formula:`SUM(E2:E${letters.length+1})`
}
alban_entropy = sorted.reduce((sum,[,count])=>sum + (-Math.log2(count/SUM)*(count/SUM)),0);

if(SURNAME_ALB && NAME_ALB && PATRONYMIC_ALB){
    const fio = (SURNAME_ALB + NAME_ALB + PATRONYMIC_ALB).toUpperCase();
    const fio_binary = stringToUTF8Binary(fio);
    const bit_count = fio_binary.replace(/\s/g,'').length;
    const info = fio.length * alban_entropy;
    
    sheet2.getCell("H12").value="ФИО:";
    sheet2.getCell("I12").value=fio;
    sheet2.getCell("H13").value="Длина:";
    sheet2.getCell("I13").value=fio.length;
    sheet2.getCell("H14").value="Информация (биты):";
    sheet2.getCell("I14").value=info;
    sheet2.getCell("H15").value="Двоичное:";
    sheet2.getCell("I15").value=fio_binary;
    sheet2.getCell("H16").value="Битов:";
    sheet2.getCell("I16").value=bit_count;
    
    sheet2.addRow([]);
    sheet2.addRow(["Вероятность ошибки","H канала","Информация (биты)"]);
    
    [0.1, 0.5, 1.0].forEach(p => {
        const H_channel = p === 0 || p === 1 ? 0 : -p*Math.log2(p) - (1-p)*Math.log2(1-p);
        const info_with_error = fio.length * (alban_entropy - H_channel);
        sheet2.addRow([p, H_channel, info_with_error]);
    });
}
}
async function bin()
{
    let chuv = stringToUTF8Binary(await fs.readFile("Чувашский.txt"))
    let alban = stringToUTF8Binary(await fs.readFile("Албанский.txt"))
    sheet3.addRow(["Чувашский",,"Албанский"])
    const chuv_bins = {
    "1": (chuv.split('1').length - 1),
    "0": (chuv.split('0').length - 1)
};
 const alban_bins = {
    "1": (alban.split('1').length - 1),
    "0": (alban.split('0').length - 1)
};
    sheet3.addRow(["1:",chuv_bins["1"],
    "1",alban_bins["1"]]);
   
    sheet3.addRow(["0:",chuv_bins["0"],
    "0",alban_bins["0"]]);
     
    chuv_binary_entropy = -Math.log2(chuv_bins["1"]/(chuv_bins["1"]+chuv_bins["0"]))*(chuv_bins["1"]/(chuv_bins["1"]+chuv_bins["0"])) +
    -Math.log2(chuv_bins["0"]/(chuv_bins["1"]+chuv_bins["0"]))*(chuv_bins["0"]/(chuv_bins["1"]+chuv_bins["0"]));
    alban_binary_entropy = -Math.log2(alban_bins["1"]/(alban_bins["1"]+alban_bins["0"]))*(alban_bins["1"]/(alban_bins["1"]+alban_bins["0"])) +
    -Math.log2(alban_bins["0"]/(alban_bins["1"]+alban_bins["0"]))*(alban_bins["0"]/(alban_bins["1"]+alban_bins["0"]));
    
    sheet3.addRow(["H:",chuv_binary_entropy,"H:",alban_binary_entropy]);
    
    if(SURNAME_CHUV && NAME_CHUV && PATRONYMIC_CHUV && SURNAME_ALB && NAME_ALB && PATRONYMIC_ALB){
        const fio_chuv = SURNAME_CHUV + NAME_CHUV + PATRONYMIC_CHUV;
        const fio_alb = SURNAME_ALB + NAME_ALB + PATRONYMIC_ALB;
        const fio_chuv_binary = stringToUTF8Binary(fio_chuv);
        const fio_alb_binary = stringToUTF8Binary(fio_alb);
        const bit_count_chuv = fio_chuv_binary.replace(/\s/g,'').length;
        const bit_count_alb = fio_alb_binary.replace(/\s/g,'').length;
        
        sheet3.addRow([]);
        sheet3.addRow(["ФИО:",fio_chuv,"ФИО:",fio_alb]);
        sheet3.addRow(["Двоичное:",fio_chuv_binary,"Двоичное:",fio_alb_binary]);
        sheet3.addRow(["Битов:",bit_count_chuv,"Битов:",bit_count_alb]);
        sheet3.addRow(["Информация (биты):",bit_count_chuv * chuv_binary_entropy,"Информация (биты):",bit_count_alb * alban_binary_entropy]);
        
        sheet3.addRow([]);
        sheet3.addRow(["Вероятность ошибки","H канала","Информация (Чувашский)","Информация (Албанский)"]);
        
        [0.1, 0.5, 1.0].forEach(p => {
            const H_channel = p === 0 || p === 1 ? 0 : -p*Math.log2(p) - (1-p)*Math.log2(1-p);
            const info_chuv = bit_count_chuv * (chuv_binary_entropy - H_channel);
            const info_alban = bit_count_alb * (alban_binary_entropy - H_channel);
            sheet3.addRow([p, H_channel, info_chuv, info_alban]);
        });
    }
}



await chuvashia();
await albania();
await bin();


const files = await fs.readdir("Reports")
const COUNT = files.length;
await workbook.xlsx.writeFile(`Reports/report${COUNT}.xlsx`)