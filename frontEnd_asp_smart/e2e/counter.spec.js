import { test, expect } from '@playwright/test'
async function login(page,email='owner@aspsmart.local',password='Owner123!') {await page.goto('/login');await page.getByLabel('Alamat email').fill(email);await page.getByLabel('Kata sandi',{exact:true}).fill(password);await page.getByRole('button',{name:'Masuk ke dashboard'}).click();await expect(page.getByRole('heading',{name:/Selamat datang,/})).toBeVisible();}
for(const width of [375,390,768,1024,1280,1440]) test(`owner pages fit ${width}px`,async({page},testInfo)=>{
 const errors=[];page.on('pageerror',e=>errors.push(e.message));
 await login(page);
 const pages=['/app','/app/pos','/app/new/cash_withdrawal','/app/new/money_transfer','/app/manage/financial-accounts','/app/ledger','/app/manage/products','/app/stock','/app/manage/branches','/app/reports','/app/cashier-sessions','/app/settings','/'];
 if([375,1440].includes(width))pages.push('/app/report-center','/app/roles','/app/stock-opnames','/app/stock-transfers','/app/wallets','/app/payables','/app/receivables','/app/daily-closings','/app/reconciliations','/app/risk-flags','/app/users','/app/approvals','/app/audit');
 {
  await page.setViewportSize({width,height:1000});
  for(const path of pages){await page.goto(path);await expect(page.locator('h1')).toBeVisible();await expect(page.locator('.skeleton')).toHaveCount(0);await expect(page.getByText('Data belum dapat dimuat')).toHaveCount(0);expect(await page.locator('h1').count(),path).toBeGreaterThan(0);const overflow=await page.evaluate(()=>document.documentElement.scrollWidth-window.innerWidth);expect(overflow,`${path} at ${width}px`).toBeLessThanOrEqual(1);}
 }
 if([375,1440].includes(width)){for(const [path,name] of [['/app','dashboard'],['/','public']]){await page.goto(path);await page.waitForLoadState('networkidle');await page.screenshot({path:testInfo.outputPath(`${name}-${width}.png`),fullPage:true});}}
 expect(errors).toEqual([]);
});
test('cashier navigation hides settings and financial adjustment',async({page})=>{await login(page,'cashier@aspsmart.local','Cashier123!');await expect(page.getByRole('link',{name:'Pengaturan',exact:true})).toHaveCount(0);await expect(page.getByRole('link',{name:'Penyesuaian saldo',exact:true})).toHaveCount(0);await page.goto('/app/settings');await expect(page.getByRole('heading',{name:'Akses tidak tersedia'})).toBeVisible();});
