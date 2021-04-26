// Copyright (c) 2021 Sho Kuroda <krdlab@gmail.com>
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

const Envsensor = require('node-omron-envsensor');

const envsensor = new Envsensor();

async function findDevice() {
  await envsensor.init();
  const devices = await envsensor.discover({ duration: 10 * 1000, quick: true });
  if (devices.length > 0) {
    return devices[0];
  } else {
    return null;
  }
}

async function main() {
  const device = await findDevice();
  if (!device) {
    throw new Error('device not found');
  }

  console.log(device.id);

  await device.connect();
  try {
    // const info = await device.getDeviceInfo();
    // console.log(JSON.stringify(info, null, 2));
    const data = await device.getLatestData();
    console.log(JSON.stringify(data, null, 2));
    const conf = await device.getBasicConfigurations();
    console.log(JSON.stringify(conf, null, 2));
  } finally {
    device.disconnect();
  }
}

main()
  .then(() => console.log('done'))
  .catch(console.error)
  .finally(() => process.exit());
