import { Flex, Input, NumberInput, Select, Text } from "@chakra-ui/react"
import { useState } from "react"
import { Token } from "../pages"
import Card from "../theme/Card"

interface CurrencyProps {
  tokens: Token[]
  selected: Token
  amount: string
  changeSelected: (t: Token) => any
  changeAmount: (amount: number) => any
}

const Currency = (props: CurrencyProps) => {
  const { tokens, selected, amount, changeSelected, changeAmount } = props

  const change = (name: string) => {
    const token = tokens.find(t => t.name === name)
    if (!token) {
      return
    }

    changeSelected(token)
  }

  const amountValue =
    Math.round(+amount * selected.value * 10000) / 10000 || "0"

  return (
    <Card>
      <Flex>
        <Select
          w="100"
          variant="filled"
          placeholder="Select coin"
          value={selected.name}
          onChange={e => change(e.target.value)}
        >
          {tokens.map(({ name }) => (
            <option value={name} key={name}>
              {name}
            </option>
          ))}
        </Select>
        <Input
          variant="unstyled"
          placeholder="0"
          textAlign="right"
          fontSize="2rem"
          fontWeight="bold"
          onChange={e => changeAmount(e.target.value)}
          value={amount}
        />
      </Flex>
      <Flex justifyContent="space-between">
        <Text colorScheme="green" fontFamily="Courier New">
          Balance: 0
        </Text>
        <Text colorScheme="green" fontFamily="Courier New">
          ≈ ${amountValue}
        </Text>
      </Flex>
    </Card>
  )
}
export default Currency
