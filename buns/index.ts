import { $ } from 'bun'

try {
  // const nvm = await $`nvm --version`.text()
  // console.log(nvm)
  await $`export=$PATH=$PATH:~/.nvm/`
  console.log(JSON.stringify(process.env, null, 2))
} catch (err) {
  console.error(err)
}
