import { Box, Button, Center, Col, H3, Row, Text } from '@tlon/indigo-react';
import React, { useCallback, useEffect } from 'react';
import useHarkState, { HarkState } from '~/logic/state/hark';
import { harkBinToId, HarkLid, Timebox } from '@urbit/api';
import { Notification } from './notification';
import usePalsState from '~/logic/state/pals';
import { PalsNotification } from '~/views/components/Pals/PalsNotification';

const unseenLid = { unseen: null };
const seenLid = { seen: null };
const selUnseen = (s: HarkState) => s.unseen;
const selSeen = (s: HarkState) => s.seen;
export function NewBox({ hideLabel = false }: { hideLabel?: boolean }) {
  const seen = useHarkState(selSeen);
  const unseen = useHarkState(selUnseen);
  const { pending, fetchPals } = usePalsState();
  const empty = Object.keys(seen).length + Object.keys(unseen).length === 0;// && pending.length === 0;

  useEffect(() => {
    fetchPals();
  }, []);

  return (
    <Box pt="2" overflowY="auto" overflowX="hidden">
      {empty ? !hideLabel &&  (
        <Center p="3">
          <Text>All clear!</Text>
        </Center>
      ) : (
        <>
          <Lid lid={unseenLid} timebox={unseen} title="Unseen" showButton />
          <Lid lid={seenLid} timebox={seen} title="Seen" />
          {/* {pending.length > 0 && (
            <Col px={2}>
              <H3 m={2}>Pending Pal Requests</H3>
              {pending.map(ship => <PalsNotification key={ship} ship={ship} />)}
            </Col>
          )} */}
        </>
      )}
    </Box>
  );
}

function Lid({
  lid,
  timebox,
  title,
  showButton = false
}: {
  lid: HarkLid;
  timebox: Timebox;
  title: string;
  showButton?: boolean;
}) {
  const markAllRead = useCallback(() => {
    useHarkState.getState().opened();
  }, []);

  if (Object.keys(timebox).length === 0) {
    return null;
  }
  return (
    <>
      <Row justifyContent="space-between">
        <Text gray p="2">
          {title}
        </Text>
        {showButton && <Button mr={2} onClick={markAllRead}>Mark All Read</Button>}
      </Row>
      <Col>
        {Object.entries(timebox)
          .sort(([, a], [, b]) => b.time - a.time)
          .map(([binId, n]) => (
            <Notification key={harkBinToId(n.bin)} lid={lid} notification={n} />
          ))}
      </Col>
    </>
  );
}
