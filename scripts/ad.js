// Copyright (c) 2021 Sho Kuroda <krdlab@gmail.com>
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

const Envsensor = require('node-omron-envsensor');

const envsensor = new Envsensor();

async function main() {
  await envsensor.init();

  envsensor.onadvertisement = (ad) => {
    console.log(JSON.stringify(ad, null, 2));
  };

  envsensor.startScan();

  await new Promise((resolve, _reject) => {
    setTimeout(() => {
      envsensor.stopScan();
      resolve();
    }, 10 * 1000);
  });
}

main()
  .then(() => console.log('done'))
  .catch(console.error)
  .finally(() => process.exit());
