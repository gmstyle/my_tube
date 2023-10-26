import 'package:flutter/material.dart';
import 'package:my_tube/models/resource_mt.dart';

class ResourceTile extends StatelessWidget {
  const ResourceTile({super.key, required this.resource});

  final ResourceMT resource;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: setTrailingIcon(),
      leading: resource.thumbnailUrl != null
          ? Image.network(
              resource.thumbnailUrl!,
            )
          : const SizedBox(
              child: Icon(Icons.place),
            ),
      title: Text(
        resource.title ?? '',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(resource.channelTitle ?? ''),
    );
  }

  Icon? setTrailingIcon() {
    switch (resource.kind) {
      case 'youtube#channel':
        return const Icon(Icons.video_collection);
      case 'youtube#playlist':
        return const Icon(Icons.playlist_play);

      default:
        return null;
    }
  }
}
