import React, { MouseEvent, ReactElement, useCallback, useEffect, useRef, useState } from 'react';
import { Associations } from '@urbit/api';
import _ from 'lodash';

import { SidebarAssociationItem, SidebarDmItem, SidebarItemBase, SidebarPendingItem } from './SidebarItem';
import useGraphState, { useInbox } from '~/logic/state/graph';
import useHarkState from '~/logic/state/hark';
import { getFeedPath, getResourcePath, modulo } from '~/logic/lib/util';
import { SidebarListConfig } from './types';
import { Workspace } from '~/types/workspace';
import useMetadataState from '~/logic/state/metadata';
import { useHistory } from 'react-router';
import { useShortcut } from '~/logic/state/settings';
import useGroupState from '~/logic/state/group';
import useInviteState from '~/logic/state/invite';
import { getGraphUnreads } from '~/views/apps/launch/components/Groups';
import { Box, Icon } from '@tlon/indigo-react';
import { IS_MOBILE } from '~/logic/lib/platform';
import { dmUnreads, getItems, sidebarSort } from './util';
import { roleForShip } from '~/logic/lib/group';

export function SidebarGroup({ baseUrl, selected, config, workspace, title }: {
  config: SidebarListConfig;
  baseUrl: string;
  selected?: string;
  title?: string;
  workspace: Workspace;
}): ReactElement {
  const groupRef = useRef<HTMLElement>(null);
  const isMessages = workspace.type === 'messages';
  const isHome = workspace.type === 'home';
  const isGroup = workspace.type === 'group';
  const groupSelected =
    (isMessages && baseUrl.includes('messages')) ||
    (isHome && baseUrl.includes('home')) ||
    (workspace.type === 'group' && (baseUrl.replace('/~landscape', '') === workspace.group || baseUrl.includes(`${workspace.group}/resource`)));
  const [collapsed, setCollapsed] = useState(!groupSelected && !isMessages);

  useEffect(() => {
    if (isGroup && groupSelected && groupRef.current) {
      groupRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  }, [isGroup, groupSelected, groupRef]);

  const { associations } = useMetadataState();
  const { groups } = useGroupState();
  const inbox = useInbox();
  const pendingDms = useGraphState(s => [...s.pendingDms].map(s => `~${s}`));
  const graphKeys = useGraphState(s => s.graphKeys);
  const pendingGroupChats = useGroupState(s => _.pickBy(s.pendingJoin, (req, rid) => !(rid in groups) && req.app === 'graph'));
  const inviteGroupChats = useInviteState(
    s => Object.values(s.invites?.['graph'] || {})
    .map(inv => `/ship/~${inv.resource.ship}/${inv.resource.name}`).filter(group => !(group in groups))
  );
  const pending = [...pendingDms, ...Object.keys(pendingGroupChats), ...inviteGroupChats];
  const { unreads, unseen } = useHarkState();

  const ordered = getItems(associations, workspace, inbox, pending)
    .sort(sidebarSort(unreads, pending)[config.sortBy]);

  const history = useHistory();

  const cycleChannels = useCallback((backward: boolean) => {
    const idx = ordered.findIndex(s => s === selected);
    const offset = backward ? -1 : 1;

    const newIdx = modulo(idx+offset, ordered.length - 1);
    const newChannel = ordered[newIdx];
    let path = '';
    if(newChannel.startsWith('~')) {
      path = `/~landscape/messages/dm/${newChannel}`;
    } else {
      const association = associations.graph[ordered[newIdx]];
      if(!association) {
        path = '/~landscape/messages';
        return;
      } else {
        const { metadata, resource } = association;
        const joined = graphKeys.has(resource.slice(7));
        if ('graph' in metadata.config) {
          path = getResourcePath(workspace, resource, joined, metadata.config.graph);
        }
      }
    }
    history.push(path);
  }, [ordered, selected, history.push]);

  useShortcut('cycleForward', useCallback((e: KeyboardEvent) => {
    cycleChannels(false);
    e.preventDefault();
  }, [cycleChannels]));

  useShortcut('cycleBack', useCallback((e: KeyboardEvent) => {
    cycleChannels(true);
    e.preventDefault();
  }, [cycleChannels]));

  let hasNotification = false;
  if (workspace.type === 'group') {
    for (const key in unseen) {
      const formattedKey = key.replace('landscape/graph', '/ship').replace('/mention', '');
      if (associations.graph[formattedKey]?.group === workspace?.group) {
        hasNotification = true;
        break;
      }
    }
  }
  const graphUnreads = getGraphUnreads(associations || ({} as Associations));
  const groupPath = isGroup ? workspace.group : '';
  const unreadCount = isGroup ? graphUnreads(groupPath) : dmUnreads(unreads);
  const hasUnread = unreadCount > 0;
  const isSynced = true;
  const isPending = false;
  const to = `/~landscape${isGroup ? workspace?.group : isMessages ? '/messages' : '/home'}`;
  const isMobileMessages = IS_MOBILE && isMessages;
  const groupTitle = title ? title : isHome ? 'My Channels' : 'Messages';
  const association = isGroup ? associations?.groups[workspace.group] : undefined;
  const feedPath = getFeedPath(association);
  const isAdmin = isGroup && roleForShip(groups[workspace.group], window.ship) === 'admin';

  return (
    <Box ref={groupRef}>
      {!isMobileMessages && <SidebarItemBase
        to={to}
        selected={groupSelected}
        hasUnread={hasUnread}
        unreadCount={unreadCount}
        isSynced={isSynced}
        title={groupTitle}
        hasNotification={hasNotification}
        pending={isPending}
        onClick={() => setCollapsed(isMessages ? false : !collapsed)}
        isGroup
        isAdmin={isAdmin}
      >
        {!isMessages && (
          <Icon
            p={1}
            pr="0"
            display="block"
            onClick={(e) => {
              e.preventDefault();
              e.stopPropagation();
              setCollapsed(!collapsed);
            }}
            icon={collapsed ? 'TriangleEast' : 'TriangleSouth'}
          />
        )}
      </SidebarItemBase>}
      {!collapsed && (
        <Box>
          {feedPath && IS_MOBILE && <SidebarItemBase
            to={`/~landscape${groupPath}/feed`}
            selected={history.location.pathname.includes('feed')}
            title="Group Feed"
            groupSelected={groupSelected}
            fontSize="13px"
            isSynced
            hasNotification={false} // How to get notifications and unreads for this?
            hasUnread={false}
            unreadCount={0}
            // unreadCount={count + each.length}
            // hasNotification={Boolean(unseen?.[`landscape${pathAsGraph}/mention`])}
            indent={1}
          >
            <Icon display="block" color="black" icon="Collection" />
          </SidebarItemBase>}
          {ordered.map((pathOrShip) => {
            const pathAsGraph = pathOrShip.replace('ship', 'graph');
            const { count, each } = unreads[pathAsGraph] || { count: 0, each: [] };

            return pathOrShip.startsWith('~') ? (
                <SidebarDmItem
                  key={pathOrShip}
                  ship={pathOrShip}
                  workspace={workspace}
                  selected={pathOrShip === selected}
                  pending={pending.includes(pathOrShip)}
                  indent={0.5}
                />
              ) : pending.includes(pathOrShip) ? (
                <SidebarPendingItem
                  key={pathOrShip}
                  path={pathOrShip}
                  selected={pathOrShip === selected}
                  indent={1}
                />
              ) : (
              <SidebarAssociationItem
                key={pathOrShip}
                selected={pathOrShip === selected}
                groupSelected={groupSelected}
                association={associations.graph[pathOrShip]}
                hideUnjoined={config.hideUnjoined}
                fontSize="13px"
                workspace={workspace}
                unreadCount={count + each.length}
                hasNotification={Boolean(unseen?.[`landscape${pathAsGraph}/mention`])}
                indent={isMessages ? 0.5 : 1}
              />
              );
          })}
        </Box>
      )}
    </Box>
  );
}
